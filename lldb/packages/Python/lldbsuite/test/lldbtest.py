"""
LLDB module which provides the abstract base class of lldb test case.

The concrete subclass can override lldbtest.TestBase in order to inherit the
common behavior for unitest.TestCase.setUp/tearDown implemented in this file.

The subclass should override the attribute mydir in order for the python runtime
to locate the individual test cases when running as part of a large test suite
or when running each test case as a separate python invocation.

./dotest.py provides a test driver which sets up the environment to run the
entire of part of the test suite .  Example:

# Exercises the test suite in the types directory....
/Volumes/data/lldb/svn/ToT/test $ ./dotest.py -A x86_64 types
...

Session logs for test failures/errors/unexpected successes will go into directory '2012-05-16-13_35_42'
Command invoked: python ./dotest.py -A x86_64 types
compilers=['clang']

Configuration: arch=x86_64 compiler=clang
----------------------------------------------------------------------
Collected 72 tests

........................................................................
----------------------------------------------------------------------
Ran 72 tests in 135.468s

OK
$
"""

from __future__ import absolute_import
from __future__ import print_function

# System modules
import abc
from distutils.version import LooseVersion
from functools import wraps
import gc
import glob
import io
import os.path
import re
import shutil
import signal
from subprocess import *
import sys
import time
import traceback
import distutils.spawn

# Third-party modules
import unittest2
from six import add_metaclass
from six import StringIO as SixStringIO
import six

# LLDB modules
import lldb
from . import configuration
from . import decorators
from . import lldbplatformutil
from . import lldbtest_config
from . import lldbutil
from . import test_categories
from lldbsuite.support import encoded_file
from lldbsuite.support import funcutils

# See also dotest.parseOptionsAndInitTestdirs(), where the environment variables
# LLDB_COMMAND_TRACE is set from '-t' option.

# By default, traceAlways is False.
if "LLDB_COMMAND_TRACE" in os.environ and os.environ[
        "LLDB_COMMAND_TRACE"] == "YES":
    traceAlways = True
else:
    traceAlways = False

# By default, doCleanup is True.
if "LLDB_DO_CLEANUP" in os.environ and os.environ["LLDB_DO_CLEANUP"] == "NO":
    doCleanup = False
else:
    doCleanup = True


#
# Some commonly used assert messages.
#

COMMAND_FAILED_AS_EXPECTED = "Command has failed as expected"

CURRENT_EXECUTABLE_SET = "Current executable set successfully"

PROCESS_IS_VALID = "Process is valid"

PROCESS_KILLED = "Process is killed successfully"

PROCESS_EXITED = "Process exited successfully"

PROCESS_STOPPED = "Process status should be stopped"

RUN_SUCCEEDED = "Process is launched successfully"

RUN_COMPLETED = "Process exited successfully"

BACKTRACE_DISPLAYED_CORRECTLY = "Backtrace displayed correctly"

BREAKPOINT_CREATED = "Breakpoint created successfully"

BREAKPOINT_STATE_CORRECT = "Breakpoint state is correct"

BREAKPOINT_PENDING_CREATED = "Pending breakpoint created successfully"

BREAKPOINT_HIT_ONCE = "Breakpoint resolved with hit count = 1"

BREAKPOINT_HIT_TWICE = "Breakpoint resolved with hit count = 2"

BREAKPOINT_HIT_THRICE = "Breakpoint resolved with hit count = 3"

MISSING_EXPECTED_REGISTERS = "At least one expected register is unavailable."

OBJECT_PRINTED_CORRECTLY = "Object printed correctly"

SOURCE_DISPLAYED_CORRECTLY = "Source code displayed correctly"

STEP_OUT_SUCCEEDED = "Thread step-out succeeded"

STOPPED_DUE_TO_EXC_BAD_ACCESS = "Process should be stopped due to bad access exception"

STOPPED_DUE_TO_ASSERT = "Process should be stopped due to an assertion"

STOPPED_DUE_TO_BREAKPOINT = "Process should be stopped due to breakpoint"

STOPPED_DUE_TO_BREAKPOINT_WITH_STOP_REASON_AS = "%s, %s" % (
    STOPPED_DUE_TO_BREAKPOINT, "instead, the actual stop reason is: '%s'")

STOPPED_DUE_TO_BREAKPOINT_CONDITION = "Stopped due to breakpoint condition"

STOPPED_DUE_TO_BREAKPOINT_IGNORE_COUNT = "Stopped due to breakpoint and ignore count"

STOPPED_DUE_TO_BREAKPOINT_JITTED_CONDITION = "Stopped due to breakpoint jitted condition"

STOPPED_DUE_TO_SIGNAL = "Process state is stopped due to signal"

STOPPED_DUE_TO_STEP_IN = "Process state is stopped due to step in"

STOPPED_DUE_TO_WATCHPOINT = "Process should be stopped due to watchpoint"

DATA_TYPES_DISPLAYED_CORRECTLY = "Data type(s) displayed correctly"

VALID_BREAKPOINT = "Got a valid breakpoint"

VALID_BREAKPOINT_LOCATION = "Got a valid breakpoint location"

VALID_COMMAND_INTERPRETER = "Got a valid command interpreter"

VALID_FILESPEC = "Got a valid filespec"

VALID_MODULE = "Got a valid module"

VALID_PROCESS = "Got a valid process"

VALID_SYMBOL = "Got a valid symbol"

VALID_TARGET = "Got a valid target"

VALID_PLATFORM = "Got a valid platform"

VALID_TYPE = "Got a valid type"

VALID_VARIABLE = "Got a valid variable"

VARIABLES_DISPLAYED_CORRECTLY = "Variable(s) displayed correctly"

WATCHPOINT_CREATED = "Watchpoint created successfully"


def CMD_MSG(str):
    '''A generic "Command '%s' returns successfully" message generator.'''
    return "Command '%s' returns successfully" % str


def COMPLETION_MSG(str_before, str_after, completions):
    '''A generic message generator for the completion mechanism.'''
    return ("'%s' successfully completes to '%s', but completions were:\n%s"
           % (str_before, str_after, "\n".join(completions)))


def EXP_MSG(str, actual, exe):
    '''A generic "'%s' returns expected result" message generator if exe.
    Otherwise, it generates "'%s' matches expected result" message.'''

    return "'%s' %s expected result, got '%s'" % (
        str, 'returns' if exe else 'matches', actual.strip())


def SETTING_MSG(setting):
    '''A generic "Value of setting '%s' is correct" message generator.'''
    return "Value of setting '%s' is correct" % setting


def line_number(filename, string_to_match):
    """Helper function to return the line number of the first matched string."""
    with io.open(filename, mode='r', encoding="utf-8") as f:
        for i, line in enumerate(f):
            if line.find(string_to_match) != -1:
                # Found our match.
                return i + 1
    raise Exception(
        "Unable to find '%s' within file %s" %
        (string_to_match, filename))

def get_line(filename, line_number):
    """Return the text of the line at the 1-based line number."""
    with io.open(filename, mode='r', encoding="utf-8") as f:
        return f.readlines()[line_number - 1]

def pointer_size():
    """Return the pointer size of the host system."""
    import ctypes
    a_pointer = ctypes.c_void_p(0xffff)
    return 8 * ctypes.sizeof(a_pointer)


def is_exe(fpath):
    """Returns true if fpath is an executable."""
    return os.path.isfile(fpath) and os.access(fpath, os.X_OK)


def which(program):
    """Returns the full path to a program; None otherwise."""
    fpath, fname = os.path.split(program)
    if fpath:
        if is_exe(program):
            return program
    else:
        for path in os.environ["PATH"].split(os.pathsep):
            exe_file = os.path.join(path, program)
            if is_exe(exe_file):
                return exe_file
    return None


class recording(SixStringIO):
    """
    A nice little context manager for recording the debugger interactions into
    our session object.  If trace flag is ON, it also emits the interactions
    into the stderr.
    """

    def __init__(self, test, trace):
        """Create a SixStringIO instance; record the session obj and trace flag."""
        SixStringIO.__init__(self)
        # The test might not have undergone the 'setUp(self)' phase yet, so that
        # the attribute 'session' might not even exist yet.
        self.session = getattr(test, "session", None) if test else None
        self.trace = trace

    def __enter__(self):
        """
        Context management protocol on entry to the body of the with statement.
        Just return the SixStringIO object.
        """
        return self

    def __exit__(self, type, value, tb):
        """
        Context management protocol on exit from the body of the with statement.
        If trace is ON, it emits the recordings into stderr.  Always add the
        recordings to our session object.  And close the SixStringIO object, too.
        """
        if self.trace:
            print(self.getvalue(), file=sys.stderr)
        if self.session:
            print(self.getvalue(), file=self.session)
        self.close()


@add_metaclass(abc.ABCMeta)
class _BaseProcess(object):

    @abc.abstractproperty
    def pid(self):
        """Returns process PID if has been launched already."""

    @abc.abstractmethod
    def launch(self, executable, args):
        """Launches new process with given executable and args."""

    @abc.abstractmethod
    def terminate(self):
        """Terminates previously launched process.."""


class _LocalProcess(_BaseProcess):

    def __init__(self, trace_on):
        self._proc = None
        self._trace_on = trace_on
        self._delayafterterminate = 0.1

    @property
    def pid(self):
        return self._proc.pid

    def launch(self, executable, args):
        self._proc = Popen(
            [executable] + args,
            stdout=open(
                os.devnull) if not self._trace_on else None,
            stdin=PIPE)

    def terminate(self):
        if self._proc.poll() is None:
            # Terminate _proc like it does the pexpect
            signals_to_try = [
                sig for sig in [
                    'SIGHUP',
                    'SIGCONT',
                    'SIGINT'] if sig in dir(signal)]
            for sig in signals_to_try:
                try:
                    self._proc.send_signal(getattr(signal, sig))
                    time.sleep(self._delayafterterminate)
                    if self._proc.poll() is not None:
                        return
                except ValueError:
                    pass  # Windows says SIGINT is not a valid signal to send
            self._proc.terminate()
            time.sleep(self._delayafterterminate)
            if self._proc.poll() is not None:
                return
            self._proc.kill()
            time.sleep(self._delayafterterminate)

    def poll(self):
        return self._proc.poll()


class _RemoteProcess(_BaseProcess):

    def __init__(self, install_remote):
        self._pid = None
        self._install_remote = install_remote

    @property
    def pid(self):
        return self._pid

    def launch(self, executable, args):
        if self._install_remote:
            src_path = executable
            dst_path = lldbutil.join_remote_paths(
                    lldb.remote_platform.GetWorkingDirectory(), os.path.basename(executable))

            dst_file_spec = lldb.SBFileSpec(dst_path, False)
            err = lldb.remote_platform.Install(
                lldb.SBFileSpec(src_path, True), dst_file_spec)
            if err.Fail():
                raise Exception(
                    "remote_platform.Install('%s', '%s') failed: %s" %
                    (src_path, dst_path, err))
        else:
            dst_path = executable
            dst_file_spec = lldb.SBFileSpec(executable, False)

        launch_info = lldb.SBLaunchInfo(args)
        launch_info.SetExecutableFile(dst_file_spec, True)
        launch_info.SetWorkingDirectory(
            lldb.remote_platform.GetWorkingDirectory())

        # Redirect stdout and stderr to /dev/null
        launch_info.AddSuppressFileAction(1, False, True)
        launch_info.AddSuppressFileAction(2, False, True)

        err = lldb.remote_platform.Launch(launch_info)
        if err.Fail():
            raise Exception(
                "remote_platform.Launch('%s', '%s') failed: %s" %
                (dst_path, args, err))
        self._pid = launch_info.GetProcessID()

    def terminate(self):
        lldb.remote_platform.Kill(self._pid)

# From 2.7's subprocess.check_output() convenience function.
# Return a tuple (stdoutdata, stderrdata).


def system(commands, **kwargs):
    r"""Run an os command with arguments and return its output as a byte string.

    If the exit code was non-zero it raises a CalledProcessError.  The
    CalledProcessError object will have the return code in the returncode
    attribute and output in the output attribute.

    The arguments are the same as for the Popen constructor.  Example:

    >>> check_output(["ls", "-l", "/dev/null"])
    'crw-rw-rw- 1 root root 1, 3 Oct 18  2007 /dev/null\n'

    The stdout argument is not allowed as it is used internally.
    To capture standard error in the result, use stderr=STDOUT.

    >>> check_output(["/bin/sh", "-c",
    ...               "ls -l non_existent_file ; exit 0"],
    ...              stderr=STDOUT)
    'ls: non_existent_file: No such file or directory\n'
    """

    # Assign the sender object to variable 'test' and remove it from kwargs.
    test = kwargs.pop('sender', None)

    # [['make', 'clean', 'foo'], ['make', 'foo']] -> ['make clean foo', 'make foo']
    commandList = [' '.join(x) for x in commands]
    output = ""
    error = ""
    for shellCommand in commandList:
        if 'stdout' in kwargs:
            raise ValueError(
                'stdout argument not allowed, it will be overridden.')
        if 'shell' in kwargs and kwargs['shell'] == False:
            raise ValueError('shell=False not allowed')
        process = Popen(
            shellCommand,
            stdout=PIPE,
            stderr=PIPE,
            shell=True,
            **kwargs)
        pid = process.pid
        this_output, this_error = process.communicate()
        retcode = process.poll()

        if retcode:
            cmd = kwargs.get("args")
            if cmd is None:
                cmd = shellCommand
            cpe = CalledProcessError(retcode, cmd)
            # Ensure caller can access the stdout/stderr.
            cpe.lldb_extensions = {
                "stdout_content": this_output,
                "stderr_content": this_error,
                "command": shellCommand
            }
            raise cpe
        output = output + this_output.decode("utf-8")
        error = error + this_error.decode("utf-8")
    return (output, error)


def getsource_if_available(obj):
    """
    Return the text of the source code for an object if available.  Otherwise,
    a print representation is returned.
    """
    import inspect
    try:
        return inspect.getsource(obj)
    except:
        return repr(obj)


def builder_module():
    if sys.platform.startswith("freebsd"):
        return __import__("builder_freebsd")
    if sys.platform.startswith("openbsd"):
        return __import__("builder_openbsd")
    if sys.platform.startswith("netbsd"):
        return __import__("builder_netbsd")
    if sys.platform.startswith("linux"):
        # sys.platform with Python-3.x returns 'linux', but with
        # Python-2.x it returns 'linux2'.
        return __import__("builder_linux")
    return __import__("builder_" + sys.platform)


class Base(unittest2.TestCase):
    """
    Abstract base for performing lldb (see TestBase) or other generic tests (see
    BenchBase for one example).  lldbtest.Base works with the test driver to
    accomplish things.

    """

    # The concrete subclass should override this attribute.
    mydir = None

    # Keep track of the old current working directory.
    oldcwd = None

    @staticmethod
    def compute_mydir(test_file):
        '''Subclasses should call this function to correctly calculate the
           required "mydir" attribute as follows:

            mydir = TestBase.compute_mydir(__file__)
        '''
        # /abs/path/to/packages/group/subdir/mytest.py -> group/subdir
        rel_prefix = test_file[len(os.environ["LLDB_TEST_SRC"]) + 1:]
        return os.path.dirname(rel_prefix)

    def TraceOn(self):
        """Returns True if we are in trace mode (tracing detailed test execution)."""
        return traceAlways

    @classmethod
    def setUpClass(cls):
        """
        Python unittest framework class setup fixture.
        Do current directory manipulation.
        """
        # Fail fast if 'mydir' attribute is not overridden.
        if not cls.mydir or len(cls.mydir) == 0:
            raise Exception("Subclasses must override the 'mydir' attribute.")

        # Save old working directory.
        cls.oldcwd = os.getcwd()

        # Change current working directory if ${LLDB_TEST_SRC} is defined.
        # See also dotest.py which sets up ${LLDB_TEST_SRC}.
        if ("LLDB_TEST_SRC" in os.environ):
            full_dir = os.path.join(os.environ["LLDB_TEST_SRC"],
                                    cls.mydir)
            if traceAlways:
                print("Change dir to:", full_dir, file=sys.stderr)
            os.chdir(full_dir)

        # Set platform context.
        cls.platformContext = lldbplatformutil.createPlatformContext()

    @classmethod
    def tearDownClass(cls):
        """
        Python unittest framework class teardown fixture.
        Do class-wide cleanup.
        """

        if doCleanup:
            # First, let's do the platform-specific cleanup.
            module = builder_module()
            module.cleanup()

            # Subclass might have specific cleanup function defined.
            if getattr(cls, "classCleanup", None):
                if traceAlways:
                    print(
                        "Call class-specific cleanup function for class:",
                        cls,
                        file=sys.stderr)
                try:
                    cls.classCleanup()
                except:
                    exc_type, exc_value, exc_tb = sys.exc_info()
                    traceback.print_exception(exc_type, exc_value, exc_tb)

        # Restore old working directory.
        if traceAlways:
            print("Restore dir to:", cls.oldcwd, file=sys.stderr)
        os.chdir(cls.oldcwd)

    def enableLogChannelsForCurrentTest(self):
        if len(lldbtest_config.channels) == 0:
            return

        # if debug channels are specified in lldbtest_config.channels,
        # create a new set of log files for every test
        log_basename = self.getLogBasenameForCurrentTest()

        # confirm that the file is writeable
        host_log_path = "{}-host.log".format(log_basename)
        open(host_log_path, 'w').close()

        log_enable = "log enable -Tpn -f {} ".format(host_log_path)
        for channel_with_categories in lldbtest_config.channels:
            channel_then_categories = channel_with_categories.split(' ', 1)
            channel = channel_then_categories[0]
            if len(channel_then_categories) > 1:
                categories = channel_then_categories[1]
            else:
                categories = "default"

            if channel == "gdb-remote" and lldb.remote_platform is None:
                # communicate gdb-remote categories to debugserver
                os.environ["LLDB_DEBUGSERVER_LOG_FLAGS"] = categories

            self.ci.HandleCommand(
                log_enable + channel_with_categories, self.res)
            if not self.res.Succeeded():
                raise Exception(
                    'log enable failed (check LLDB_LOG_OPTION env variable)')

        # Communicate log path name to debugserver & lldb-server
        # For remote debugging, these variables need to be set when starting the platform
        # instance.
        if lldb.remote_platform is None:
            server_log_path = "{}-server.log".format(log_basename)
            open(server_log_path, 'w').close()
            os.environ["LLDB_DEBUGSERVER_LOG_FILE"] = server_log_path

            # Communicate channels to lldb-server
            os.environ["LLDB_SERVER_LOG_CHANNELS"] = ":".join(
                lldbtest_config.channels)

        self.addTearDownHook(self.disableLogChannelsForCurrentTest)

    def disableLogChannelsForCurrentTest(self):
        # close all log files that we opened
        for channel_and_categories in lldbtest_config.channels:
            # channel format - <channel-name> [<category0> [<category1> ...]]
            channel = channel_and_categories.split(' ', 1)[0]
            self.ci.HandleCommand("log disable " + channel, self.res)
            if not self.res.Succeeded():
                raise Exception(
                    'log disable failed (check LLDB_LOG_OPTION env variable)')

        # Retrieve the server log (if any) from the remote system. It is assumed the server log
        # is writing to the "server.log" file in the current test directory. This can be
        # achieved by setting LLDB_DEBUGSERVER_LOG_FILE="server.log" when starting remote
        # platform. If the remote logging is not enabled, then just let the Get() command silently
        # fail.
        if lldb.remote_platform:
            lldb.remote_platform.Get(
                lldb.SBFileSpec("server.log"), lldb.SBFileSpec(
                    self.getLogBasenameForCurrentTest() + "-server.log"))

    def setPlatformWorkingDir(self):
        if not lldb.remote_platform or not configuration.lldb_platform_working_dir:
            return

        components = self.mydir.split(os.path.sep) + [str(self.test_number), self.getBuildDirBasename()]
        remote_test_dir = configuration.lldb_platform_working_dir
        for c in components:
            remote_test_dir = lldbutil.join_remote_paths(remote_test_dir, c)
            error = lldb.remote_platform.MakeDirectory(
                remote_test_dir, 448)  # 448 = 0o700
            if error.Fail():
                raise Exception("making remote directory '%s': %s" % (
                    remote_test_dir, error))

        lldb.remote_platform.SetWorkingDirectory(remote_test_dir)

        # This function removes all files from the current working directory while leaving
        # the directories in place. The cleanup is required to reduce the disk space required
        # by the test suite while leaving the directories untouched is neccessary because
        # sub-directories might belong to an other test
        def clean_working_directory():
            # TODO: Make it working on Windows when we need it for remote debugging support
            # TODO: Replace the heuristic to remove the files with a logic what collects the
            # list of files we have to remove during test runs.
            shell_cmd = lldb.SBPlatformShellCommand(
                "rm %s/*" % remote_test_dir)
            lldb.remote_platform.Run(shell_cmd)
        self.addTearDownHook(clean_working_directory)

    def getSourceDir(self):
        """Return the full path to the current test."""
        return os.path.join(os.environ["LLDB_TEST_SRC"], self.mydir)

    def getBuildDirBasename(self):
        return self.__class__.__module__ + "." + self.testMethodName

    def getBuildDir(self):
        """Return the full path to the current test."""
        return os.path.join(os.environ["LLDB_BUILD"], self.mydir,
                            self.getBuildDirBasename())


    def makeBuildDir(self):
        """Create the test-specific working directory, deleting any previous
        contents."""
        # See also dotest.py which sets up ${LLDB_BUILD}.
        bdir = self.getBuildDir()
        if os.path.isdir(bdir):
            shutil.rmtree(bdir)
        lldbutil.mkdir_p(bdir)

    def getBuildArtifact(self, name="a.out"):
        """Return absolute path to an artifact in the test's build directory."""
        return os.path.join(self.getBuildDir(), name)

    def getSourcePath(self, name):
        """Return absolute path to a file in the test's source directory."""
        return os.path.join(self.getSourceDir(), name)

    @classmethod
    def setUpCommands(cls):
        commands = [
            # First of all, clear all settings to have clean state of global properties.
            "settings clear -all",

            # Disable Spotlight lookup. The testsuite creates
            # different binaries with the same UUID, because they only
            # differ in the debug info, which is not being hashed.
            "settings set symbols.enable-external-lookup false",

            # Disable fix-its by default so that incorrect expressions in tests don't
            # pass just because Clang thinks it has a fix-it.
            "settings set target.auto-apply-fixits false",

            # Testsuite runs in parallel and the host can have also other load.
            "settings set plugin.process.gdb-remote.packet-timeout 60",

            'settings set symbols.clang-modules-cache-path "{}"'.format(
                configuration.lldb_module_cache_dir),
            "settings set use-color false",
        ]

        # Set any user-overridden settings.
        for setting, value in configuration.settings:
            commands.append('setting set %s %s'%(setting, value))

        # Make sure that a sanitizer LLDB's environment doesn't get passed on.
        if cls.platformContext and cls.platformContext.shlib_environment_var in os.environ:
            commands.append('settings set target.env-vars {}='.format(
                cls.platformContext.shlib_environment_var))

        # Set environment variables for the inferior.
        if lldbtest_config.inferior_env:
            commands.append('settings set target.env-vars {}'.format(
                lldbtest_config.inferior_env))
        return commands

    def setUp(self):
        """Fixture for unittest test case setup.

        It works with the test driver to conditionally skip tests and does other
        initializations."""
        #import traceback
        # traceback.print_stack()

        if "LIBCXX_PATH" in os.environ:
            self.libcxxPath = os.environ["LIBCXX_PATH"]
        else:
            self.libcxxPath = None

        if "LLDBVSCODE_EXEC" in os.environ:
            self.lldbVSCodeExec = os.environ["LLDBVSCODE_EXEC"]
        else:
            self.lldbVSCodeExec = None

        self.lldbOption = " ".join(
            "-o '" + s + "'" for s in self.setUpCommands())

        # If we spawn an lldb process for test (via pexpect), do not load the
        # init file unless told otherwise.
        if os.environ.get("NO_LLDBINIT") != "NO":
            self.lldbOption += " --no-lldbinit"

        # Assign the test method name to self.testMethodName.
        #
        # For an example of the use of this attribute, look at test/types dir.
        # There are a bunch of test cases under test/types and we don't want the
        # module cacheing subsystem to be confused with executable name "a.out"
        # used for all the test cases.
        self.testMethodName = self._testMethodName

        # This is for the case of directly spawning 'lldb'/'gdb' and interacting
        # with it using pexpect.
        self.child = None
        self.child_prompt = "(lldb) "
        # If the child is interacting with the embedded script interpreter,
        # there are two exits required during tear down, first to quit the
        # embedded script interpreter and second to quit the lldb command
        # interpreter.
        self.child_in_script_interpreter = False

        # These are for customized teardown cleanup.
        self.dict = None
        self.doTearDownCleanup = False
        # And in rare cases where there are multiple teardown cleanups.
        self.dicts = []
        self.doTearDownCleanups = False

        # List of spawned subproces.Popen objects
        self.subprocesses = []

        # List of forked process PIDs
        self.forkedProcessPids = []

        # Create a string buffer to record the session info, to be dumped into a
        # test case specific file if test failure is encountered.
        self.log_basename = self.getLogBasenameForCurrentTest()

        session_file = "{}.log".format(self.log_basename)
        # Python 3 doesn't support unbuffered I/O in text mode.  Open buffered.
        self.session = encoded_file.open(session_file, "utf-8", mode="w")

        # Optimistically set __errored__, __failed__, __expected__ to False
        # initially.  If the test errored/failed, the session info
        # (self.session) is then dumped into a session specific file for
        # diagnosis.
        self.__cleanup_errored__ = False
        self.__errored__ = False
        self.__failed__ = False
        self.__expected__ = False
        # We are also interested in unexpected success.
        self.__unexpected__ = False
        # And skipped tests.
        self.__skipped__ = False

        # See addTearDownHook(self, hook) which allows the client to add a hook
        # function to be run during tearDown() time.
        self.hooks = []

        # See HideStdout(self).
        self.sys_stdout_hidden = False

        if self.platformContext:
            # set environment variable names for finding shared libraries
            self.dylibPath = self.platformContext.shlib_environment_var

        # Create the debugger instance.
        self.dbg = lldb.SBDebugger.Create()
        # Copy selected platform from a global instance if it exists.
        if lldb.selected_platform is not None:
            self.dbg.SetSelectedPlatform(lldb.selected_platform)

        if not self.dbg:
            raise Exception('Invalid debugger instance')

        # Retrieve the associated command interpreter instance.
        self.ci = self.dbg.GetCommandInterpreter()
        if not self.ci:
            raise Exception('Could not get the command interpreter')

        # And the result object.
        self.res = lldb.SBCommandReturnObject()

        self.setPlatformWorkingDir()
        self.enableLogChannelsForCurrentTest()

        lib_dir = os.environ["LLDB_LIB_DIR"]
        self.dsym = None
        self.framework_dir = None
        self.darwinWithFramework = self.platformIsDarwin()
        if sys.platform.startswith("darwin"):
            # Handle the framework environment variable if it is set
            if hasattr(lldbtest_config, 'lldb_framework_path'):
                framework_path = lldbtest_config.lldb_framework_path
                # Framework dir should be the directory containing the framework
                self.framework_dir = framework_path[:framework_path.rfind('LLDB.framework')]
            # If a framework dir was not specified assume the Xcode build
            # directory layout where the framework is in LLDB_LIB_DIR.
            else:
                self.framework_dir = lib_dir
            self.dsym = os.path.join(self.framework_dir, 'LLDB.framework', 'LLDB')
            # If the framework binary doesn't exist, assume we didn't actually
            # build a framework, and fallback to standard *nix behavior by
            # setting framework_dir and dsym to None.
            if not os.path.exists(self.dsym):
                self.framework_dir = None
                self.dsym = None
                self.darwinWithFramework = False
        self.makeBuildDir()

    def setAsync(self, value):
        """ Sets async mode to True/False and ensures it is reset after the testcase completes."""
        old_async = self.dbg.GetAsync()
        self.dbg.SetAsync(value)
        self.addTearDownHook(lambda: self.dbg.SetAsync(old_async))

    def cleanupSubprocesses(self):
        # Ensure any subprocesses are cleaned up
        for p in self.subprocesses:
            p.terminate()
            del p
        del self.subprocesses[:]
        # Ensure any forked processes are cleaned up
        for pid in self.forkedProcessPids:
            if os.path.exists("/proc/" + str(pid)):
                os.kill(pid, signal.SIGTERM)

    def spawnSubprocess(self, executable, args=[], install_remote=True):
        """ Creates a subprocess.Popen object with the specified executable and arguments,
            saves it in self.subprocesses, and returns the object.
            NOTE: if using this function, ensure you also call:

              self.addTearDownHook(self.cleanupSubprocesses)

            otherwise the test suite will leak processes.
        """
        proc = _RemoteProcess(
            install_remote) if lldb.remote_platform else _LocalProcess(self.TraceOn())
        proc.launch(executable, args)
        self.subprocesses.append(proc)
        return proc

    def forkSubprocess(self, executable, args=[]):
        """ Fork a subprocess with its own group ID.
            NOTE: if using this function, ensure you also call:

              self.addTearDownHook(self.cleanupSubprocesses)

            otherwise the test suite will leak processes.
        """
        child_pid = os.fork()
        if child_pid == 0:
            # If more I/O support is required, this can be beefed up.
            fd = os.open(os.devnull, os.O_RDWR)
            os.dup2(fd, 1)
            os.dup2(fd, 2)
            # This call causes the child to have its of group ID
            os.setpgid(0, 0)
            os.execvp(executable, [executable] + args)
        # Give the child time to get through the execvp() call
        time.sleep(0.1)
        self.forkedProcessPids.append(child_pid)
        return child_pid

    def HideStdout(self):
        """Hide output to stdout from the user.

        During test execution, there might be cases where we don't want to show the
        standard output to the user.  For example,

            self.runCmd(r'''sc print("\n\n\tHello!\n")''')

        tests whether command abbreviation for 'script' works or not.  There is no
        need to show the 'Hello' output to the user as long as the 'script' command
        succeeds and we are not in TraceOn() mode (see the '-t' option).

        In this case, the test method calls self.HideStdout(self) to redirect the
        sys.stdout to a null device, and restores the sys.stdout upon teardown.

        Note that you should only call this method at most once during a test case
        execution.  Any subsequent call has no effect at all."""
        if self.sys_stdout_hidden:
            return

        self.sys_stdout_hidden = True
        old_stdout = sys.stdout
        sys.stdout = open(os.devnull, 'w')

        def restore_stdout():
            sys.stdout = old_stdout
        self.addTearDownHook(restore_stdout)

    # =======================================================================
    # Methods for customized teardown cleanups as well as execution of hooks.
    # =======================================================================

    def setTearDownCleanup(self, dictionary=None):
        """Register a cleanup action at tearDown() time with a dictionary"""
        self.dict = dictionary
        self.doTearDownCleanup = True

    def addTearDownCleanup(self, dictionary):
        """Add a cleanup action at tearDown() time with a dictionary"""
        self.dicts.append(dictionary)
        self.doTearDownCleanups = True

    def addTearDownHook(self, hook):
        """
        Add a function to be run during tearDown() time.

        Hooks are executed in a first come first serve manner.
        """
        if six.callable(hook):
            with recording(self, traceAlways) as sbuf:
                print(
                    "Adding tearDown hook:",
                    getsource_if_available(hook),
                    file=sbuf)
            self.hooks.append(hook)

        return self

    def deletePexpectChild(self):
        # This is for the case of directly spawning 'lldb' and interacting with it
        # using pexpect.
        if self.child and self.child.isalive():
            import pexpect
            with recording(self, traceAlways) as sbuf:
                print("tearing down the child process....", file=sbuf)
            try:
                if self.child_in_script_interpreter:
                    self.child.sendline('quit()')
                    self.child.expect_exact(self.child_prompt)
                self.child.sendline(
                    'settings set interpreter.prompt-on-quit false')
                self.child.sendline('quit')
                self.child.expect(pexpect.EOF)
            except (ValueError, pexpect.ExceptionPexpect):
                # child is already terminated
                pass
            except OSError as exception:
                import errno
                if exception.errno != errno.EIO:
                    # unexpected error
                    raise
                # child is already terminated
            finally:
                # Give it one final blow to make sure the child is terminated.
                self.child.close()

    def tearDown(self):
        """Fixture for unittest test case teardown."""
        #import traceback
        # traceback.print_stack()

        self.deletePexpectChild()

        # Check and run any hook functions.
        for hook in reversed(self.hooks):
            with recording(self, traceAlways) as sbuf:
                print(
                    "Executing tearDown hook:",
                    getsource_if_available(hook),
                    file=sbuf)
            if funcutils.requires_self(hook):
                hook(self)
            else:
                hook()  # try the plain call and hope it works

        del self.hooks

        # Perform registered teardown cleanup.
        if doCleanup and self.doTearDownCleanup:
            self.cleanup(dictionary=self.dict)

        # In rare cases where there are multiple teardown cleanups added.
        if doCleanup and self.doTearDownCleanups:
            if self.dicts:
                for dict in reversed(self.dicts):
                    self.cleanup(dictionary=dict)

        # This must be the last statement, otherwise teardown hooks or other
        # lines might depend on this still being active.
        lldb.SBDebugger.Destroy(self.dbg)
        del self.dbg

    # =========================================================
    # Various callbacks to allow introspection of test progress
    # =========================================================

    def markError(self):
        """Callback invoked when an error (unexpected exception) errored."""
        self.__errored__ = True
        with recording(self, False) as sbuf:
            # False because there's no need to write "ERROR" to the stderr twice.
            # Once by the Python unittest framework, and a second time by us.
            print("ERROR", file=sbuf)

    def markCleanupError(self):
        """Callback invoked when an error occurs while a test is cleaning up."""
        self.__cleanup_errored__ = True
        with recording(self, False) as sbuf:
            # False because there's no need to write "CLEANUP_ERROR" to the stderr twice.
            # Once by the Python unittest framework, and a second time by us.
            print("CLEANUP_ERROR", file=sbuf)

    def markFailure(self):
        """Callback invoked when a failure (test assertion failure) occurred."""
        self.__failed__ = True
        with recording(self, False) as sbuf:
            # False because there's no need to write "FAIL" to the stderr twice.
            # Once by the Python unittest framework, and a second time by us.
            print("FAIL", file=sbuf)

    def markExpectedFailure(self, err, bugnumber):
        """Callback invoked when an expected failure/error occurred."""
        self.__expected__ = True
        with recording(self, False) as sbuf:
            # False because there's no need to write "expected failure" to the
            # stderr twice.
            # Once by the Python unittest framework, and a second time by us.
            if bugnumber is None:
                print("expected failure", file=sbuf)
            else:
                print(
                    "expected failure (problem id:" + str(bugnumber) + ")",
                    file=sbuf)

    def markSkippedTest(self):
        """Callback invoked when a test is skipped."""
        self.__skipped__ = True
        with recording(self, False) as sbuf:
            # False because there's no need to write "skipped test" to the
            # stderr twice.
            # Once by the Python unittest framework, and a second time by us.
            print("skipped test", file=sbuf)

    def markUnexpectedSuccess(self, bugnumber):
        """Callback invoked when an unexpected success occurred."""
        self.__unexpected__ = True
        with recording(self, False) as sbuf:
            # False because there's no need to write "unexpected success" to the
            # stderr twice.
            # Once by the Python unittest framework, and a second time by us.
            if bugnumber is None:
                print("unexpected success", file=sbuf)
            else:
                print(
                    "unexpected success (problem id:" + str(bugnumber) + ")",
                    file=sbuf)

    def getRerunArgs(self):
        return " -f %s.%s" % (self.__class__.__name__, self._testMethodName)

    def getLogBasenameForCurrentTest(self, prefix=None):
        """
        returns a partial path that can be used as the beginning of the name of multiple
        log files pertaining to this test

        <session-dir>/<arch>-<compiler>-<test-file>.<test-class>.<test-method>
        """
        dname = os.path.join(os.environ["LLDB_TEST_SRC"],
                             os.environ["LLDB_SESSION_DIRNAME"])
        if not os.path.isdir(dname):
            os.mkdir(dname)

        components = []
        if prefix is not None:
            components.append(prefix)
        for c in configuration.session_file_format:
            if c == 'f':
                components.append(self.__class__.__module__)
            elif c == 'n':
                components.append(self.__class__.__name__)
            elif c == 'c':
                compiler = self.getCompiler()

                if compiler[1] == ':':
                    compiler = compiler[2:]
                if os.path.altsep is not None:
                    compiler = compiler.replace(os.path.altsep, os.path.sep)
                path_components = [x for x in compiler.split(os.path.sep) if x != ""]

                # Add at most 4 path components to avoid generating very long
                # filenames
                components.extend(path_components[-4:])
            elif c == 'a':
                components.append(self.getArchitecture())
            elif c == 'm':
                components.append(self.testMethodName)
        fname = "-".join(components)

        return os.path.join(dname, fname)

    def dumpSessionInfo(self):
        """
        Dump the debugger interactions leading to a test error/failure.  This
        allows for more convenient postmortem analysis.

        See also LLDBTestResult (dotest.py) which is a singlton class derived
        from TextTestResult and overwrites addError, addFailure, and
        addExpectedFailure methods to allow us to to mark the test instance as
        such.
        """

        # We are here because self.tearDown() detected that this test instance
        # either errored or failed.  The lldb.test_result singleton contains
        # two lists (errors and failures) which get populated by the unittest
        # framework.  Look over there for stack trace information.
        #
        # The lists contain 2-tuples of TestCase instances and strings holding
        # formatted tracebacks.
        #
        # See http://docs.python.org/library/unittest.html#unittest.TestResult.

        # output tracebacks into session
        pairs = []
        if self.__errored__:
            pairs = configuration.test_result.errors
            prefix = 'Error'
        elif self.__cleanup_errored__:
            pairs = configuration.test_result.cleanup_errors
            prefix = 'CleanupError'
        elif self.__failed__:
            pairs = configuration.test_result.failures
            prefix = 'Failure'
        elif self.__expected__:
            pairs = configuration.test_result.expectedFailures
            prefix = 'ExpectedFailure'
        elif self.__skipped__:
            prefix = 'SkippedTest'
        elif self.__unexpected__:
            prefix = 'UnexpectedSuccess'
        else:
            prefix = 'Success'

        if not self.__unexpected__ and not self.__skipped__:
            for test, traceback in pairs:
                if test is self:
                    print(traceback, file=self.session)

        import datetime
        print(
            "Session info generated @",
            datetime.datetime.now().ctime(),
            file=self.session)
        self.session.close()
        del self.session

        # process the log files
        log_files_for_this_test = glob.glob(self.log_basename + "*")

        if prefix != 'Success' or lldbtest_config.log_success:
            # keep all log files, rename them to include prefix
            dst_log_basename = self.getLogBasenameForCurrentTest(prefix)
            for src in log_files_for_this_test:
                if os.path.isfile(src):
                    dst = src.replace(self.log_basename, dst_log_basename)
                    if os.name == "nt" and os.path.isfile(dst):
                        # On Windows, renaming a -> b will throw an exception if
                        # b exists.  On non-Windows platforms it silently
                        # replaces the destination.  Ultimately this means that
                        # atomic renames are not guaranteed to be possible on
                        # Windows, but we need this to work anyway, so just
                        # remove the destination first if it already exists.
                        remove_file(dst)

                    lldbutil.mkdir_p(os.path.dirname(dst))
                    os.rename(src, dst)
        else:
            # success!  (and we don't want log files) delete log files
            for log_file in log_files_for_this_test:
                remove_file(log_file)

    # ====================================================
    # Config. methods supported through a plugin interface
    # (enables reading of the current test configuration)
    # ====================================================

    def isMIPS(self):
        """Returns true if the architecture is MIPS."""
        arch = self.getArchitecture()
        if re.match("mips", arch):
            return True
        return False

    def isPPC64le(self):
        """Returns true if the architecture is PPC64LE."""
        arch = self.getArchitecture()
        if re.match("powerpc64le", arch):
            return True
        return False

    def getArchitecture(self):
        """Returns the architecture in effect the test suite is running with."""
        module = builder_module()
        arch = module.getArchitecture()
        if arch == 'amd64':
            arch = 'x86_64'
        if arch in ['armv7l', 'armv8l'] :
            arch = 'arm'
        return arch

    def getLldbArchitecture(self):
        """Returns the architecture of the lldb binary."""
        if not hasattr(self, 'lldbArchitecture'):

            # spawn local process
            command = [
                lldbtest_config.lldbExec,
                "-o",
                "file " + lldbtest_config.lldbExec,
                "-o",
                "quit"
            ]

            output = check_output(command)
            str = output.decode("utf-8")

            for line in str.splitlines():
                m = re.search(
                    "Current executable set to '.*' \\((.*)\\)\\.", line)
                if m:
                    self.lldbArchitecture = m.group(1)
                    break

        return self.lldbArchitecture

    def getCompiler(self):
        """Returns the compiler in effect the test suite is running with."""
        module = builder_module()
        return module.getCompiler()

    def getCompilerBinary(self):
        """Returns the compiler binary the test suite is running with."""
        return self.getCompiler().split()[0]

    def getCompilerVersion(self):
        """ Returns a string that represents the compiler version.
            Supports: llvm, clang.
        """
        version = 'unknown'

        compiler = self.getCompilerBinary()
        version_output = system([[compiler, "-v"]])[1]
        for line in version_output.split(os.linesep):
            m = re.search('version ([0-9\.]+)', line)
            if m:
                version = m.group(1)
        return version

    def getDwarfVersion(self):
        """ Returns the dwarf version generated by clang or '0'. """
        if configuration.dwarf_version:
            return str(configuration.dwarf_version)
        if 'clang' in self.getCompiler():
            try:
                driver_output = check_output(
                    [self.getCompiler()] + '-g -c -x c - -o - -###'.split(),
                    stderr=STDOUT)
                driver_output = driver_output.decode("utf-8")
                for line in driver_output.split(os.linesep):
                    m = re.search('dwarf-version=([0-9])', line)
                    if m:
                        return m.group(1)
            except: pass
        return '0'

    def platformIsDarwin(self):
        """Returns true if the OS triple for the selected platform is any valid apple OS"""
        return lldbplatformutil.platformIsDarwin()

    def hasDarwinFramework(self):
        return self.darwinWithFramework

    def getPlatform(self):
        """Returns the target platform the test suite is running on."""
        return lldbplatformutil.getPlatform()

    def isIntelCompiler(self):
        """ Returns true if using an Intel (ICC) compiler, false otherwise. """
        return any([x in self.getCompiler() for x in ["icc", "icpc", "icl"]])

    def expectedCompilerVersion(self, compiler_version):
        """Returns True iff compiler_version[1] matches the current compiler version.
           Use compiler_version[0] to specify the operator used to determine if a match has occurred.
           Any operator other than the following defaults to an equality test:
             '>', '>=', "=>", '<', '<=', '=<', '!=', "!" or 'not'
        """
        if (compiler_version is None):
            return True
        operator = str(compiler_version[0])
        version = compiler_version[1]

        if (version is None):
            return True
        if (operator == '>'):
            return LooseVersion(self.getCompilerVersion()) > LooseVersion(version)
        if (operator == '>=' or operator == '=>'):
            return LooseVersion(self.getCompilerVersion()) >= LooseVersion(version)
        if (operator == '<'):
            return LooseVersion(self.getCompilerVersion()) < LooseVersion(version)
        if (operator == '<=' or operator == '=<'):
            return LooseVersion(self.getCompilerVersion()) <= LooseVersion(version)
        if (operator == '!=' or operator == '!' or operator == 'not'):
            return str(version) not in str(self.getCompilerVersion())
        return str(version) in str(self.getCompilerVersion())

    def expectedCompiler(self, compilers):
        """Returns True iff any element of compilers is a sub-string of the current compiler."""
        if (compilers is None):
            return True

        for compiler in compilers:
            if compiler in self.getCompiler():
                return True

        return False

    def expectedArch(self, archs):
        """Returns True iff any element of archs is a sub-string of the current architecture."""
        if (archs is None):
            return True

        for arch in archs:
            if arch in self.getArchitecture():
                return True

        return False

    def getRunOptions(self):
        """Command line option for -A and -C to run this test again, called from
        self.dumpSessionInfo()."""
        arch = self.getArchitecture()
        comp = self.getCompiler()
        option_str = ""
        if arch:
            option_str = "-A " + arch
        if comp:
            option_str += " -C " + comp
        return option_str

    def getDebugInfo(self):
        method = getattr(self, self.testMethodName)
        return getattr(method, "debug_info", None)

    # ==================================================
    # Build methods supported through a plugin interface
    # ==================================================

    def getstdlibFlag(self):
        """ Returns the proper -stdlib flag, or empty if not required."""
        if self.platformIsDarwin() or self.getPlatform() == "freebsd" or self.getPlatform() == "openbsd":
            stdlibflag = "-stdlib=libc++"
        else:  # this includes NetBSD
            stdlibflag = ""
        return stdlibflag

    def getstdFlag(self):
        """ Returns the proper stdflag. """
        if "gcc" in self.getCompiler() and "4.6" in self.getCompilerVersion():
            stdflag = "-std=c++0x"
        else:
            stdflag = "-std=c++11"
        return stdflag

    def buildDriver(self, sources, exe_name):
        """ Platform-specific way to build a program that links with LLDB (via the liblldb.so
            or LLDB.framework).
        """
        stdflag = self.getstdFlag()
        stdlibflag = self.getstdlibFlag()

        lib_dir = configuration.lldb_libs_dir
        if self.hasDarwinFramework():
            d = {'CXX_SOURCES': sources,
                 'EXE': exe_name,
                 'CFLAGS_EXTRAS': "%s %s" % (stdflag, stdlibflag),
                 'FRAMEWORK_INCLUDES': "-F%s" % self.framework_dir,
                 'LD_EXTRAS': "%s -Wl,-rpath,%s" % (self.dsym, self.framework_dir),
                 }
        elif sys.platform.startswith('win'):
            d = {
                'CXX_SOURCES': sources,
                'EXE': exe_name,
                'CFLAGS_EXTRAS': "%s %s -I%s" % (stdflag,
                                                 stdlibflag,
                                                 os.path.join(
                                                     os.environ["LLDB_SRC"],
                                                     "include")),
                'LD_EXTRAS': "-L%s -lliblldb" % os.environ["LLDB_IMPLIB_DIR"]}
        else:
            d = {
                'CXX_SOURCES': sources,
                'EXE': exe_name,
                'CFLAGS_EXTRAS': "%s %s -I%s" % (stdflag,
                                                 stdlibflag,
                                                 os.path.join(
                                                     os.environ["LLDB_SRC"],
                                                     "include")),
                'LD_EXTRAS': "-L%s -llldb -Wl,-rpath,%s" % (lib_dir, lib_dir)}
        if self.TraceOn():
            print(
                "Building LLDB Driver (%s) from sources %s" %
                (exe_name, sources))

        self.buildDefault(dictionary=d)

    def buildLibrary(self, sources, lib_name):
        """Platform specific way to build a default library. """

        stdflag = self.getstdFlag()

        lib_dir = configuration.lldb_libs_dir
        if self.hasDarwinFramework():
            d = {'DYLIB_CXX_SOURCES': sources,
                 'DYLIB_NAME': lib_name,
                 'CFLAGS_EXTRAS': "%s -stdlib=libc++" % stdflag,
                 'FRAMEWORK_INCLUDES': "-F%s" % self.framework_dir,
                 'LD_EXTRAS': "%s -Wl,-rpath,%s -dynamiclib" % (self.dsym, self.framework_dir),
                 }
        elif self.getPlatform() == 'windows':
            d = {
                'DYLIB_CXX_SOURCES': sources,
                'DYLIB_NAME': lib_name,
                'CFLAGS_EXTRAS': "%s -I%s " % (stdflag,
                                               os.path.join(
                                                   os.environ["LLDB_SRC"],
                                                   "include")),
                'LD_EXTRAS': "-shared -l%s\liblldb.lib" % self.os.environ["LLDB_IMPLIB_DIR"]}
        else:
            d = {
                'DYLIB_CXX_SOURCES': sources,
                'DYLIB_NAME': lib_name,
                'CFLAGS_EXTRAS': "%s -I%s -fPIC" % (stdflag,
                                                    os.path.join(
                                                        os.environ["LLDB_SRC"],
                                                        "include")),
                'LD_EXTRAS': "-shared -L%s -llldb -Wl,-rpath,%s" % (lib_dir, lib_dir)}
        if self.TraceOn():
            print(
                "Building LLDB Library (%s) from sources %s" %
                (lib_name, sources))

        self.buildDefault(dictionary=d)

    def buildProgram(self, sources, exe_name):
        """ Platform specific way to build an executable from C/C++ sources. """
        d = {'CXX_SOURCES': sources,
             'EXE': exe_name}
        self.buildDefault(dictionary=d)

    def buildDefault(
            self,
            architecture=None,
            compiler=None,
            dictionary=None):
        """Platform specific way to build the default binaries."""
        testdir = self.mydir
        testname = self.getBuildDirBasename()
        if self.getDebugInfo():
            raise Exception("buildDefault tests must set NO_DEBUG_INFO_TESTCASE")
        module = builder_module()
        dictionary = lldbplatformutil.finalize_build_dictionary(dictionary)
        if not module.buildDefault(self, architecture, compiler,
                                   dictionary, testdir, testname):
            raise Exception("Don't know how to build default binary")

    def buildDsym(
            self,
            architecture=None,
            compiler=None,
            dictionary=None):
        """Platform specific way to build binaries with dsym info."""
        testdir = self.mydir
        testname = self.getBuildDirBasename()
        if self.getDebugInfo() != "dsym":
            raise Exception("NO_DEBUG_INFO_TESTCASE must build with buildDefault")

        module = builder_module()
        dictionary = lldbplatformutil.finalize_build_dictionary(dictionary)
        if not module.buildDsym(self, architecture, compiler,
                                dictionary, testdir, testname):
            raise Exception("Don't know how to build binary with dsym")

    def buildDwarf(
            self,
            architecture=None,
            compiler=None,
            dictionary=None):
        """Platform specific way to build binaries with dwarf maps."""
        testdir = self.mydir
        testname = self.getBuildDirBasename()
        if self.getDebugInfo() != "dwarf":
            raise Exception("NO_DEBUG_INFO_TESTCASE must build with buildDefault")

        module = builder_module()
        dictionary = lldbplatformutil.finalize_build_dictionary(dictionary)
        if not module.buildDwarf(self, architecture, compiler,
                                   dictionary, testdir, testname):
            raise Exception("Don't know how to build binary with dwarf")

    def buildDwo(
            self,
            architecture=None,
            compiler=None,
            dictionary=None):
        """Platform specific way to build binaries with dwarf maps."""
        testdir = self.mydir
        testname = self.getBuildDirBasename()
        if self.getDebugInfo() != "dwo":
            raise Exception("NO_DEBUG_INFO_TESTCASE must build with buildDefault")

        module = builder_module()
        dictionary = lldbplatformutil.finalize_build_dictionary(dictionary)
        if not module.buildDwo(self, architecture, compiler,
                                   dictionary, testdir, testname):
            raise Exception("Don't know how to build binary with dwo")

    def buildGModules(
            self,
            architecture=None,
            compiler=None,
            dictionary=None):
        """Platform specific way to build binaries with gmodules info."""
        testdir = self.mydir
        testname = self.getBuildDirBasename()
        if self.getDebugInfo() != "gmodules":
            raise Exception("NO_DEBUG_INFO_TESTCASE must build with buildDefault")

        module = builder_module()
        dictionary = lldbplatformutil.finalize_build_dictionary(dictionary)
        if not module.buildGModules(self, architecture, compiler,
                                    dictionary, testdir, testname):
            raise Exception("Don't know how to build binary with gmodules")

    def signBinary(self, binary_path):
        if sys.platform.startswith("darwin"):
            codesign_cmd = "codesign --force --sign \"%s\" %s" % (
                lldbtest_config.codesign_identity, binary_path)
            call(codesign_cmd, shell=True)

    def findBuiltClang(self):
        """Tries to find and use Clang from the build directory as the compiler (instead of the system compiler)."""
        paths_to_try = [
            "llvm-build/Release+Asserts/x86_64/bin/clang",
            "llvm-build/Debug+Asserts/x86_64/bin/clang",
            "llvm-build/Release/x86_64/bin/clang",
            "llvm-build/Debug/x86_64/bin/clang",
        ]
        lldb_root_path = os.path.join(
            os.path.dirname(__file__), "..", "..", "..", "..")
        for p in paths_to_try:
            path = os.path.join(lldb_root_path, p)
            if os.path.exists(path):
                return path

        # Tries to find clang at the same folder as the lldb
        lldb_dir = os.path.dirname(lldbtest_config.lldbExec)
        path = distutils.spawn.find_executable("clang", lldb_dir)
        if path is not None:
            return path

        return os.environ["CC"]

    def findYaml2obj(self):
        """
        Get the path to the yaml2obj executable, which can be used to create
        test object files from easy to write yaml instructions.

        Throws an Exception if the executable cannot be found.
        """
        # Tries to find yaml2obj at the same folder as clang
        clang_dir = os.path.dirname(self.findBuiltClang())
        path = distutils.spawn.find_executable("yaml2obj", clang_dir)
        if path is not None:
            return path
        raise Exception("yaml2obj executable not found")


    def yaml2obj(self, yaml_path, obj_path):
        """
        Create an object file at the given path from a yaml file.

        Throws subprocess.CalledProcessError if the object could not be created.
        """
        yaml2obj = self.findYaml2obj()
        command = [yaml2obj, "-o=%s" % obj_path, yaml_path]
        system([command])

    def getBuildFlags(
            self,
            use_cpp11=True,
            use_libcxx=False,
            use_libstdcxx=False):
        """ Returns a dictionary (which can be provided to build* functions above) which
            contains OS-specific build flags.
        """
        cflags = ""
        ldflags = ""

        # On Mac OS X, unless specifically requested to use libstdc++, use
        # libc++
        if not use_libstdcxx and self.platformIsDarwin():
            use_libcxx = True

        if use_libcxx and self.libcxxPath:
            cflags += "-stdlib=libc++ "
            if self.libcxxPath:
                libcxxInclude = os.path.join(self.libcxxPath, "include")
                libcxxLib = os.path.join(self.libcxxPath, "lib")
                if os.path.isdir(libcxxInclude) and os.path.isdir(libcxxLib):
                    cflags += "-nostdinc++ -I%s -L%s -Wl,-rpath,%s " % (
                        libcxxInclude, libcxxLib, libcxxLib)

        if use_cpp11:
            cflags += "-std="
            if "gcc" in self.getCompiler() and "4.6" in self.getCompilerVersion():
                cflags += "c++0x"
            else:
                cflags += "c++11"
        if self.platformIsDarwin() or self.getPlatform() == "freebsd":
            cflags += " -stdlib=libc++"
        elif self.getPlatform() == "openbsd":
            cflags += " -stdlib=libc++"
        elif self.getPlatform() == "netbsd":
            # NetBSD defaults to libc++
            pass
        elif "clang" in self.getCompiler():
            cflags += " -stdlib=libstdc++"

        return {'CFLAGS_EXTRAS': cflags,
                'LD_EXTRAS': ldflags,
                }

    def cleanup(self, dictionary=None):
        """Platform specific way to do cleanup after build."""
        module = builder_module()
        if not module.cleanup(self, dictionary):
            raise Exception(
                "Don't know how to do cleanup with dictionary: " +
                dictionary)

    def getLLDBLibraryEnvVal(self):
        """ Returns the path that the OS-specific library search environment variable
            (self.dylibPath) should be set to in order for a program to find the LLDB
            library. If an environment variable named self.dylibPath is already set,
            the new path is appended to it and returned.
        """
        existing_library_path = os.environ[
            self.dylibPath] if self.dylibPath in os.environ else None
        lib_dir = os.environ["LLDB_LIB_DIR"]
        if existing_library_path:
            return "%s:%s" % (existing_library_path, lib_dir)
        elif sys.platform.startswith("darwin"):
            return os.path.join(lib_dir, 'LLDB.framework')
        else:
            return lib_dir

    def getLibcPlusPlusLibs(self):
        if self.getPlatform() in ('freebsd', 'linux', 'netbsd', 'openbsd'):
            return ['libc++.so.1']
        else:
            return ['libc++.1.dylib', 'libc++abi.']

# Metaclass for TestBase to change the list of test metods when a new TestCase is loaded.
# We change the test methods to create a new test method for each test for each debug info we are
# testing. The name of the new test method will be '<original-name>_<debug-info>' and with adding
# the new test method we remove the old method at the same time. This functionality can be
# supressed by at test case level setting the class attribute NO_DEBUG_INFO_TESTCASE or at test
# level by using the decorator @no_debug_info_test.


class LLDBTestCaseFactory(type):

    def __new__(cls, name, bases, attrs):
        original_testcase = super(
            LLDBTestCaseFactory, cls).__new__(
            cls, name, bases, attrs)
        if original_testcase.NO_DEBUG_INFO_TESTCASE:
            return original_testcase

        newattrs = {}
        for attrname, attrvalue in attrs.items():
            if attrname.startswith("test") and not getattr(
                    attrvalue, "__no_debug_info_test__", False):

                # If any debug info categories were explicitly tagged, assume that list to be
                # authoritative.  If none were specified, try with all debug
                # info formats.
                all_dbginfo_categories = set(test_categories.debug_info_categories)
                categories = set(
                    getattr(
                        attrvalue,
                        "categories",
                        [])) & all_dbginfo_categories
                if not categories:
                    categories = all_dbginfo_categories

                for cat in categories:
                    @decorators.add_test_categories([cat])
                    @wraps(attrvalue)
                    def test_method(self, attrvalue=attrvalue):
                        return attrvalue(self)

                    method_name = attrname + "_" + cat
                    test_method.__name__ = method_name
                    test_method.debug_info = cat
                    newattrs[method_name] = test_method

            else:
                newattrs[attrname] = attrvalue
        return super(
            LLDBTestCaseFactory,
            cls).__new__(
            cls,
            name,
            bases,
            newattrs)

# Setup the metaclass for this class to change the list of the test
# methods when a new class is loaded


@add_metaclass(LLDBTestCaseFactory)
class TestBase(Base):
    """
    This abstract base class is meant to be subclassed.  It provides default
    implementations for setUpClass(), tearDownClass(), setUp(), and tearDown(),
    among other things.

    Important things for test class writers:

        - Overwrite the mydir class attribute, otherwise your test class won't
          run.  It specifies the relative directory to the top level 'test' so
          the test harness can change to the correct working directory before
          running your test.

        - The setUp method sets up things to facilitate subsequent interactions
          with the debugger as part of the test.  These include:
              - populate the test method name
              - create/get a debugger set with synchronous mode (self.dbg)
              - get the command interpreter from with the debugger (self.ci)
              - create a result object for use with the command interpreter
                (self.res)
              - plus other stuffs

        - The tearDown method tries to perform some necessary cleanup on behalf
          of the test to return the debugger to a good state for the next test.
          These include:
              - execute any tearDown hooks registered by the test method with
                TestBase.addTearDownHook(); examples can be found in
                settings/TestSettings.py
              - kill the inferior process associated with each target, if any,
                and, then delete the target from the debugger's target list
              - perform build cleanup before running the next test method in the
                same test class; examples of registering for this service can be
                found in types/TestIntegerTypes.py with the call:
                    - self.setTearDownCleanup(dictionary=d)

        - Similarly setUpClass and tearDownClass perform classwise setup and
          teardown fixtures.  The tearDownClass method invokes a default build
          cleanup for the entire test class;  also, subclasses can implement the
          classmethod classCleanup(cls) to perform special class cleanup action.

        - The instance methods runCmd and expect are used heavily by existing
          test cases to send a command to the command interpreter and to perform
          string/pattern matching on the output of such command execution.  The
          expect method also provides a mode to peform string/pattern matching
          without running a command.

        - The build methods buildDefault, buildDsym, and buildDwarf are used to
          build the binaries used during a particular test scenario.  A plugin
          should be provided for the sys.platform running the test suite.  The
          Mac OS X implementation is located in plugins/darwin.py.
    """

    # Subclasses can set this to true (if they don't depend on debug info) to avoid running the
    # test multiple times with various debug info types.
    NO_DEBUG_INFO_TESTCASE = False

    # Maximum allowed attempts when launching the inferior process.
    # Can be overridden by the LLDB_MAX_LAUNCH_COUNT environment variable.
    maxLaunchCount = 1

    # Time to wait before the next launching attempt in second(s).
    # Can be overridden by the LLDB_TIME_WAIT_NEXT_LAUNCH environment variable.
    timeWaitNextLaunch = 1.0

    def generateSource(self, source):
        template = source + '.template'
        temp = os.path.join(self.getSourceDir(), template)
        with open(temp, 'r') as f:
            content = f.read()

        public_api_dir = os.path.join(
            os.environ["LLDB_SRC"], "include", "lldb", "API")

        # Look under the include/lldb/API directory and add #include statements
        # for all the SB API headers.
        public_headers = os.listdir(public_api_dir)
        # For different platforms, the include statement can vary.
        if self.hasDarwinFramework():
            include_stmt = "'#include <%s>' % os.path.join('LLDB', header)"
        else:
            include_stmt = "'#include <%s>' % os.path.join('" + public_api_dir + "', header)"
        list = [eval(include_stmt) for header in public_headers if (
            header.startswith("SB") and header.endswith(".h"))]
        includes = '\n'.join(list)
        new_content = content.replace('%include_SB_APIs%', includes)
        src = os.path.join(self.getBuildDir(), source)
        with open(src, 'w') as f:
            f.write(new_content)

        self.addTearDownHook(lambda: os.remove(src))

    def setUp(self):
        #import traceback
        # traceback.print_stack()

        # Works with the test driver to conditionally skip tests via
        # decorators.
        Base.setUp(self)

        for s in self.setUpCommands():
            self.runCmd(s)

        if "LLDB_MAX_LAUNCH_COUNT" in os.environ:
            self.maxLaunchCount = int(os.environ["LLDB_MAX_LAUNCH_COUNT"])

        if "LLDB_TIME_WAIT_NEXT_LAUNCH" in os.environ:
            self.timeWaitNextLaunch = float(
                os.environ["LLDB_TIME_WAIT_NEXT_LAUNCH"])

        # We want our debugger to be synchronous.
        self.dbg.SetAsync(False)

        # Retrieve the associated command interpreter instance.
        self.ci = self.dbg.GetCommandInterpreter()
        if not self.ci:
            raise Exception('Could not get the command interpreter')

        # And the result object.
        self.res = lldb.SBCommandReturnObject()

    def registerSharedLibrariesWithTarget(self, target, shlibs):
        '''If we are remotely running the test suite, register the shared libraries with the target so they get uploaded, otherwise do nothing

        Any modules in the target that have their remote install file specification set will
        get uploaded to the remote host. This function registers the local copies of the
        shared libraries with the target and sets their remote install locations so they will
        be uploaded when the target is run.
        '''
        if not shlibs or not self.platformContext:
            return None

        shlib_environment_var = self.platformContext.shlib_environment_var
        shlib_prefix = self.platformContext.shlib_prefix
        shlib_extension = '.' + self.platformContext.shlib_extension

        working_dir = self.get_process_working_directory()
        environment = ['%s=%s' % (shlib_environment_var, working_dir)]
        # Add any shared libraries to our target if remote so they get
        # uploaded into the working directory on the remote side
        for name in shlibs:
            # The path can be a full path to a shared library, or a make file name like "Foo" for
            # "libFoo.dylib" or "libFoo.so", or "Foo.so" for "Foo.so" or "libFoo.so", or just a
            # basename like "libFoo.so". So figure out which one it is and resolve the local copy
            # of the shared library accordingly
            if os.path.isfile(name):
                local_shlib_path = name  # name is the full path to the local shared library
            else:
                # Check relative names
                local_shlib_path = os.path.join(
                    self.getBuildDir(), shlib_prefix + name + shlib_extension)
                if not os.path.exists(local_shlib_path):
                    local_shlib_path = os.path.join(
                        self.getBuildDir(), name + shlib_extension)
                    if not os.path.exists(local_shlib_path):
                        local_shlib_path = os.path.join(self.getBuildDir(), name)

                # Make sure we found the local shared library in the above code
                self.assertTrue(os.path.exists(local_shlib_path))

            # Add the shared library to our target
            shlib_module = target.AddModule(local_shlib_path, None, None, None)
            if lldb.remote_platform:
                # We must set the remote install location if we want the shared library
                # to get uploaded to the remote target
                remote_shlib_path = lldbutil.append_to_process_working_directory(self,
                    os.path.basename(local_shlib_path))
                shlib_module.SetRemoteInstallFileSpec(
                    lldb.SBFileSpec(remote_shlib_path, False))

        return environment

    def registerSanitizerLibrariesWithTarget(self, target):
        runtimes = []
        for m in target.module_iter():
            libspec = m.GetFileSpec()
            if "clang_rt" in libspec.GetFilename():
                runtimes.append(os.path.join(libspec.GetDirectory(),
                                             libspec.GetFilename()))
        return self.registerSharedLibrariesWithTarget(target, runtimes)

    # utility methods that tests can use to access the current objects
    def target(self):
        if not self.dbg:
            raise Exception('Invalid debugger instance')
        return self.dbg.GetSelectedTarget()

    def process(self):
        if not self.dbg:
            raise Exception('Invalid debugger instance')
        return self.dbg.GetSelectedTarget().GetProcess()

    def thread(self):
        if not self.dbg:
            raise Exception('Invalid debugger instance')
        return self.dbg.GetSelectedTarget().GetProcess().GetSelectedThread()

    def frame(self):
        if not self.dbg:
            raise Exception('Invalid debugger instance')
        return self.dbg.GetSelectedTarget().GetProcess(
        ).GetSelectedThread().GetSelectedFrame()

    def get_process_working_directory(self):
        '''Get the working directory that should be used when launching processes for local or remote processes.'''
        if lldb.remote_platform:
            # Remote tests set the platform working directory up in
            # TestBase.setUp()
            return lldb.remote_platform.GetWorkingDirectory()
        else:
            # local tests change directory into each test subdirectory
            return self.getBuildDir()

    def tearDown(self):
        #import traceback
        # traceback.print_stack()

        # Ensure all the references to SB objects have gone away so that we can
        # be sure that all test-specific resources have been freed before we
        # attempt to delete the targets.
        gc.collect()

        # Delete the target(s) from the debugger as a general cleanup step.
        # This includes terminating the process for each target, if any.
        # We'd like to reuse the debugger for our next test without incurring
        # the initialization overhead.
        targets = []
        for target in self.dbg:
            if target:
                targets.append(target)
                process = target.GetProcess()
                if process:
                    rc = self.invoke(process, "Kill")
                    self.assertTrue(rc.Success(), PROCESS_KILLED)
        for target in targets:
            self.dbg.DeleteTarget(target)

        # Do this last, to make sure it's in reverse order from how we setup.
        Base.tearDown(self)

    def switch_to_thread_with_stop_reason(self, stop_reason):
        """
        Run the 'thread list' command, and select the thread with stop reason as
        'stop_reason'.  If no such thread exists, no select action is done.
        """
        from .lldbutil import stop_reason_to_str
        self.runCmd('thread list')
        output = self.res.GetOutput()
        thread_line_pattern = re.compile(
            "^[ *] thread #([0-9]+):.*stop reason = %s" %
            stop_reason_to_str(stop_reason))
        for line in output.splitlines():
            matched = thread_line_pattern.match(line)
            if matched:
                self.runCmd('thread select %s' % matched.group(1))

    def runCmd(self, cmd, msg=None, check=True, trace=False, inHistory=False):
        """
        Ask the command interpreter to handle the command and then check its
        return status.
        """
        # Fail fast if 'cmd' is not meaningful.
        if not cmd or len(cmd) == 0:
            raise Exception("Bad 'cmd' parameter encountered")

        trace = (True if traceAlways else trace)

        if cmd.startswith("target create "):
            cmd = cmd.replace("target create ", "file ")

        running = (cmd.startswith("run") or cmd.startswith("process launch"))

        for i in range(self.maxLaunchCount if running else 1):
            self.ci.HandleCommand(cmd, self.res, inHistory)

            with recording(self, trace) as sbuf:
                print("runCmd:", cmd, file=sbuf)
                if not check:
                    print("check of return status not required", file=sbuf)
                if self.res.Succeeded():
                    print("output:", self.res.GetOutput(), file=sbuf)
                else:
                    print("runCmd failed!", file=sbuf)
                    print(self.res.GetError(), file=sbuf)

            if self.res.Succeeded():
                break
            elif running:
                # For process launch, wait some time before possible next try.
                time.sleep(self.timeWaitNextLaunch)
                with recording(self, trace) as sbuf:
                    print("Command '" + cmd + "' failed!", file=sbuf)

        if check:
            output = ""
            if self.res.GetOutput():
                output += "\nCommand output:\n" + self.res.GetOutput()
            if self.res.GetError():
                output += "\nError output:\n" + self.res.GetError()
            if msg:
                msg += output
            if cmd:
                cmd += output
            self.assertTrue(self.res.Succeeded(),
                            msg if (msg) else CMD_MSG(cmd))

    def match(
            self,
            str,
            patterns,
            msg=None,
            trace=False,
            error=False,
            matching=True,
            exe=True):
        """run command in str, and match the result against regexp in patterns returning the match object for the first matching pattern

        Otherwise, all the arguments have the same meanings as for the expect function"""

        trace = (True if traceAlways else trace)

        if exe:
            # First run the command.  If we are expecting error, set check=False.
            # Pass the assert message along since it provides more semantic
            # info.
            self.runCmd(
                str,
                msg=msg,
                trace=(
                    True if trace else False),
                check=not error)

            # Then compare the output against expected strings.
            output = self.res.GetError() if error else self.res.GetOutput()

            # If error is True, the API client expects the command to fail!
            if error:
                self.assertFalse(self.res.Succeeded(),
                                 "Command '" + str + "' is expected to fail!")
        else:
            # No execution required, just compare str against the golden input.
            output = str
            with recording(self, trace) as sbuf:
                print("looking at:", output, file=sbuf)

        # The heading says either "Expecting" or "Not expecting".
        heading = "Expecting" if matching else "Not expecting"

        for pattern in patterns:
            # Match Objects always have a boolean value of True.
            match_object = re.search(pattern, output)
            matched = bool(match_object)
            with recording(self, trace) as sbuf:
                print("%s pattern: %s" % (heading, pattern), file=sbuf)
                print("Matched" if matched else "Not matched", file=sbuf)
            if matched:
                break

        self.assertTrue(matched if matching else not matched,
                        msg if msg else EXP_MSG(str, output, exe))

        return match_object

    def check_completion_with_desc(self, str_input, match_desc_pairs):
        interp = self.dbg.GetCommandInterpreter()
        match_strings = lldb.SBStringList()
        description_strings = lldb.SBStringList()
        num_matches = interp.HandleCompletionWithDescriptions(str_input, len(str_input), 0, -1, match_strings, description_strings)
        self.assertEqual(len(description_strings), len(match_strings))

        missing_pairs = []
        for pair in match_desc_pairs:
            found_pair = False
            for i in range(num_matches + 1):
                match_candidate = match_strings.GetStringAtIndex(i)
                description_candidate = description_strings.GetStringAtIndex(i)
                if match_candidate == pair[0] and description_candidate == pair[1]:
                    found_pair = True
                    break
            if not found_pair:
                missing_pairs.append(pair)

        if len(missing_pairs):
            error_msg = "Missing pairs:\n"
            for pair in missing_pairs:
                error_msg += " [" + pair[0] + ":" + pair[1] + "]\n"
            error_msg += "Got the following " + str(num_matches) + " completions back:\n"
            for i in range(num_matches + 1):
                match_candidate = match_strings.GetStringAtIndex(i)
                description_candidate = description_strings.GetStringAtIndex(i)
                error_msg += "[" + match_candidate + ":" + description_candidate + "]\n"
            self.assertEqual(0, len(missing_pairs), error_msg)

    def complete_exactly(self, str_input, patterns):
        self.complete_from_to(str_input, patterns, True)

    def complete_from_to(self, str_input, patterns, turn_off_re_match=False):
        """Test that the completion mechanism completes str_input to patterns,
        where patterns could be a pattern-string or a list of pattern-strings"""
        # Patterns should not be None in order to proceed.
        self.assertFalse(patterns is None)
        # And should be either a string or list of strings.  Check for list type
        # below, if not, make a list out of the singleton string.  If patterns
        # is not a string or not a list of strings, there'll be runtime errors
        # later on.
        if not isinstance(patterns, list):
            patterns = [patterns]

        interp = self.dbg.GetCommandInterpreter()
        match_strings = lldb.SBStringList()
        num_matches = interp.HandleCompletion(str_input, len(str_input), 0, -1, match_strings)
        common_match = match_strings.GetStringAtIndex(0)
        if num_matches == 0:
            compare_string = str_input
        else:
            if common_match != None and len(common_match) > 0:
                compare_string = str_input + common_match
            else:
                compare_string = ""
                for idx in range(1, num_matches+1):
                    compare_string += match_strings.GetStringAtIndex(idx) + "\n"

        for p in patterns:
            if turn_off_re_match:
                self.expect(
                    compare_string, msg=COMPLETION_MSG(
                        str_input, p, match_strings), exe=False, substrs=[p])
            else:
                self.expect(
                    compare_string, msg=COMPLETION_MSG(
                        str_input, p, match_strings), exe=False, patterns=[p])

    def completions_match(self, command, completions):
        """Checks that the completions for the given command are equal to the
        given list of completions"""
        interp = self.dbg.GetCommandInterpreter()
        match_strings = lldb.SBStringList()
        interp.HandleCompletion(command, len(command), 0, -1, match_strings)
        # match_strings is a 1-indexed list, so we have to slice...
        self.assertItemsEqual(completions, list(match_strings)[1:],
                              "List of returned completion is wrong")

    def filecheck(
            self,
            command,
            check_file,
            filecheck_options = '',
            expect_cmd_failure = False):
        # Run the command.
        self.runCmd(
                command,
                check=(not expect_cmd_failure),
                msg="FileCheck'ing result of `{0}`".format(command))

        self.assertTrue((not expect_cmd_failure) == self.res.Succeeded())

        # Get the error text if there was an error, and the regular text if not.
        output = self.res.GetOutput() if self.res.Succeeded() \
                else self.res.GetError()

        # Assemble the absolute path to the check file. As a convenience for
        # LLDB inline tests, assume that the check file is a relative path to
        # a file within the inline test directory.
        if check_file.endswith('.pyc'):
            check_file = check_file[:-1]
        check_file_abs = os.path.abspath(check_file)

        # Run FileCheck.
        filecheck_bin = configuration.get_filecheck_path()
        if not filecheck_bin:
            self.assertTrue(False, "No valid FileCheck executable specified")
        filecheck_args = [filecheck_bin, check_file_abs]
        if filecheck_options:
            filecheck_args.append(filecheck_options)
        subproc = Popen(filecheck_args, stdin=PIPE, stdout=PIPE, stderr=PIPE, universal_newlines = True)
        cmd_stdout, cmd_stderr = subproc.communicate(input=output)
        cmd_status = subproc.returncode

        filecheck_cmd = " ".join(filecheck_args)
        filecheck_trace = """
--- FileCheck trace (code={0}) ---
{1}

FileCheck input:
{2}

FileCheck output:
{3}
{4}
""".format(cmd_status, filecheck_cmd, output, cmd_stdout, cmd_stderr)

        trace = cmd_status != 0 or traceAlways
        with recording(self, trace) as sbuf:
            print(filecheck_trace, file=sbuf)

        self.assertTrue(cmd_status == 0)

    def expect(
            self,
            str,
            msg=None,
            patterns=None,
            startstr=None,
            endstr=None,
            substrs=None,
            trace=False,
            error=False,
            ordered=True,
            matching=True,
            exe=True,
            inHistory=False):
        """
        Similar to runCmd; with additional expect style output matching ability.

        Ask the command interpreter to handle the command and then check its
        return status.  The 'msg' parameter specifies an informational assert
        message.  We expect the output from running the command to start with
        'startstr', matches the substrings contained in 'substrs', and regexp
        matches the patterns contained in 'patterns'.

        When matching is true and ordered is true, which are both the default,
        the strings in the substrs array have to appear in the command output
        in the order in which they appear in the array.

        If the keyword argument error is set to True, it signifies that the API
        client is expecting the command to fail.  In this case, the error stream
        from running the command is retrieved and compared against the golden
        input, instead.

        If the keyword argument matching is set to False, it signifies that the API
        client is expecting the output of the command not to match the golden
        input.

        Finally, the required argument 'str' represents the lldb command to be
        sent to the command interpreter.  In case the keyword argument 'exe' is
        set to False, the 'str' is treated as a string to be matched/not-matched
        against the golden input.
        """
        trace = (True if traceAlways else trace)

        if exe:
            # First run the command.  If we are expecting error, set check=False.
            # Pass the assert message along since it provides more semantic
            # info.
            self.runCmd(
                str,
                msg=msg,
                trace=(
                    True if trace else False),
                check=not error,
                inHistory=inHistory)

            # Then compare the output against expected strings.
            output = self.res.GetError() if error else self.res.GetOutput()

            # If error is True, the API client expects the command to fail!
            if error:
                self.assertFalse(self.res.Succeeded(),
                                 "Command '" + str + "' is expected to fail!")
        else:
            # No execution required, just compare str against the golden input.
            if isinstance(str, lldb.SBCommandReturnObject):
                output = str.GetOutput()
            else:
                output = str
            with recording(self, trace) as sbuf:
                print("looking at:", output, file=sbuf)

        # The heading says either "Expecting" or "Not expecting".
        heading = "Expecting" if matching else "Not expecting"

        # Start from the startstr, if specified.
        # If there's no startstr, set the initial state appropriately.
        matched = output.startswith(startstr) if startstr else (
            True if matching else False)

        if startstr:
            with recording(self, trace) as sbuf:
                print("%s start string: %s" % (heading, startstr), file=sbuf)
                print("Matched" if matched else "Not matched", file=sbuf)

        # Look for endstr, if specified.
        keepgoing = matched if matching else not matched
        if endstr:
            matched = output.endswith(endstr)
            with recording(self, trace) as sbuf:
                print("%s end string: %s" % (heading, endstr), file=sbuf)
                print("Matched" if matched else "Not matched", file=sbuf)

        # Look for sub strings, if specified.
        keepgoing = matched if matching else not matched
        if substrs and keepgoing:
            start = 0
            for substr in substrs:
                index = output[start:].find(substr)
                start = start + index if ordered and matching else 0
                matched = index != -1
                with recording(self, trace) as sbuf:
                    print("%s sub string: %s" % (heading, substr), file=sbuf)
                    print("Matched" if matched else "Not matched", file=sbuf)
                keepgoing = matched if matching else not matched
                if not keepgoing:
                    break

        # Search for regular expression patterns, if specified.
        keepgoing = matched if matching else not matched
        if patterns and keepgoing:
            for pattern in patterns:
                # Match Objects always have a boolean value of True.
                matched = bool(re.search(pattern, output))
                with recording(self, trace) as sbuf:
                    print("%s pattern: %s" % (heading, pattern), file=sbuf)
                    print("Matched" if matched else "Not matched", file=sbuf)
                keepgoing = matched if matching else not matched
                if not keepgoing:
                    break

        self.assertTrue(matched if matching else not matched,
                        msg + "\nCommand output:\n" + EXP_MSG(str, output, exe)
                        if msg else EXP_MSG(str, output, exe))

    def expect_expr(
            self,
            expr,
            result_summary=None,
            result_value=None,
            result_type=None,
            ):
        """
        Evaluates the given expression and verifies the result.
        :param expr: The expression as a string.
        :param result_summary: The summary that the expression should have. None if the summary should not be checked.
        :param result_value: The value that the expression should have. None if the value should not be checked.
        :param result_type: The type that the expression result should have. None if the type should not be checked.
        """
        self.assertTrue(expr.strip() == expr, "Expression contains trailing/leading whitespace: '" + expr + "'")

        frame = self.frame()
        options = lldb.SBExpressionOptions()

        # Disable fix-its that tests don't pass by accident.
        options.SetAutoApplyFixIts(False)

        # Set the usual default options for normal expressions.
        options.SetIgnoreBreakpoints(True)

        if self.frame().IsValid():
          options.SetLanguage(frame.GuessLanguage())
          eval_result = self.frame().EvaluateExpression(expr, options)
        else:
          eval_result = self.target().EvaluateExpression(expr, options)

        if not eval_result.GetError().Success():
            self.assertTrue(eval_result.GetError().Success(),
                "Unexpected failure with msg: " + eval_result.GetError().GetCString())

        if result_type:
            self.assertEqual(result_type, eval_result.GetDisplayTypeName())

        if result_value:
            self.assertEqual(result_value, eval_result.GetValue())

        if result_summary:
            self.assertEqual(result_summary, eval_result.GetSummary())

    def invoke(self, obj, name, trace=False):
        """Use reflection to call a method dynamically with no argument."""
        trace = (True if traceAlways else trace)

        method = getattr(obj, name)
        import inspect
        self.assertTrue(inspect.ismethod(method),
                        name + "is a method name of object: " + str(obj))
        result = method()
        with recording(self, trace) as sbuf:
            print(str(method) + ":", result, file=sbuf)
        return result

    def build(
            self,
            architecture=None,
            compiler=None,
            dictionary=None):
        """Platform specific way to build the default binaries."""
        module = builder_module()

        dictionary = lldbplatformutil.finalize_build_dictionary(dictionary)
        if self.getDebugInfo() is None:
            return self.buildDefault(architecture, compiler, dictionary)
        elif self.getDebugInfo() == "dsym":
            return self.buildDsym(architecture, compiler, dictionary)
        elif self.getDebugInfo() == "dwarf":
            return self.buildDwarf(architecture, compiler, dictionary)
        elif self.getDebugInfo() == "dwo":
            return self.buildDwo(architecture, compiler, dictionary)
        elif self.getDebugInfo() == "gmodules":
            return self.buildGModules(architecture, compiler, dictionary)
        else:
            self.fail("Can't build for debug info: %s" % self.getDebugInfo())

    def run_platform_command(self, cmd):
        platform = self.dbg.GetSelectedPlatform()
        shell_command = lldb.SBPlatformShellCommand(cmd)
        err = platform.Run(shell_command)
        return (err, shell_command.GetStatus(), shell_command.GetOutput())

    # =================================================
    # Misc. helper methods for debugging test execution
    # =================================================

    def DebugSBValue(self, val):
        """Debug print a SBValue object, if traceAlways is True."""
        from .lldbutil import value_type_to_str

        if not traceAlways:
            return

        err = sys.stderr
        err.write(val.GetName() + ":\n")
        err.write('\t' + "TypeName         -> " + val.GetTypeName() + '\n')
        err.write('\t' + "ByteSize         -> " +
                  str(val.GetByteSize()) + '\n')
        err.write('\t' + "NumChildren      -> " +
                  str(val.GetNumChildren()) + '\n')
        err.write('\t' + "Value            -> " + str(val.GetValue()) + '\n')
        err.write('\t' + "ValueAsUnsigned  -> " +
                  str(val.GetValueAsUnsigned()) + '\n')
        err.write(
            '\t' +
            "ValueType        -> " +
            value_type_to_str(
                val.GetValueType()) +
            '\n')
        err.write('\t' + "Summary          -> " + str(val.GetSummary()) + '\n')
        err.write('\t' + "IsPointerType    -> " +
                  str(val.TypeIsPointerType()) + '\n')
        err.write('\t' + "Location         -> " + val.GetLocation() + '\n')

    def DebugSBType(self, type):
        """Debug print a SBType object, if traceAlways is True."""
        if not traceAlways:
            return

        err = sys.stderr
        err.write(type.GetName() + ":\n")
        err.write('\t' + "ByteSize        -> " +
                  str(type.GetByteSize()) + '\n')
        err.write('\t' + "IsPointerType   -> " +
                  str(type.IsPointerType()) + '\n')
        err.write('\t' + "IsReferenceType -> " +
                  str(type.IsReferenceType()) + '\n')

    def DebugPExpect(self, child):
        """Debug the spwaned pexpect object."""
        if not traceAlways:
            return

        print(child)

    @classmethod
    def RemoveTempFile(cls, file):
        if os.path.exists(file):
            remove_file(file)

# On Windows, the first attempt to delete a recently-touched file can fail
# because of a race with antimalware scanners.  This function will detect a
# failure and retry.


def remove_file(file, num_retries=1, sleep_duration=0.5):
    for i in range(num_retries + 1):
        try:
            os.remove(file)
            return True
        except:
            time.sleep(sleep_duration)
            continue
    return False
