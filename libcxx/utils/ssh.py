#===----------------------------------------------------------------------===##
#
# Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
# See https://llvm.org/LICENSE.txt for license information.
# SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
#
#===----------------------------------------------------------------------===##

"""
Runs an executable on a remote host.

This is meant to be used as an executor when running the C++ Standard Library
conformance test suite.
"""

import argparse
import os
import posixpath
import subprocess
import sys


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('--host', type=str, required=True)
    parser.add_argument('--codesign_identity', type=str, required=False)
    parser.add_argument('--dependencies', type=str, nargs='*', required=True)
    parser.add_argument('--env', type=str, nargs='*', required=True)
    (args, remaining) = parser.parse_known_args(sys.argv[1:])

    if len(remaining) < 2:
        sys.stderr.write('Missing actual commands to run')
        return 1

    commandLine = remaining[1:] # Skip the '--'

    ssh = lambda command: ['ssh', '-oBatchMode=yes', args.host, command]
    scp = lambda src, dst: ['scp', '-oBatchMode=yes', '-r', src, '{}:{}'.format(args.host, dst)]

    # Create a temporary directory where the test will be run.
    tmp = subprocess.check_output(ssh('mktemp -d /tmp/libcxx.XXXXXXXXXX'), universal_newlines=True).strip()

    # HACK:
    # If an argument is a file that ends in `.tmp.exe`, assume it is the name
    # of an executable generated by a test file. We call these test-executables
    # below. This allows us to do custom processing like codesigning test-executables
    # and changing their path when running on the remote host. It's also possible
    # for there to be no such executable, for example in the case of a .sh.cpp
    # test.
    isTestExe = lambda exe: exe.endswith('.tmp.exe') and os.path.exists(exe)
    testExeOnRemote = lambda exe: posixpath.join(tmp, os.path.basename(exe))

    try:
        # Do any necessary codesigning of test-executables found in the command line.
        if args.codesign_identity:
            for exe in filter(isTestExe, commandLine):
                rc = subprocess.call(['xcrun', 'codesign', '-f', '-s', args.codesign_identity, exe], env={})
                if rc != 0:
                    sys.stderr.write('Failed to codesign: {}'.format(exe))
                    return rc

        # Ensure the test dependencies exist and scp them to the temporary directory.
        # Test dependencies can be either files or directories, so the `scp` command
        # needs to use `-r`.
        for dep in args.dependencies:
            if not os.path.exists(dep):
                sys.stderr.write('Missing file or directory {} marked as a dependency of a test'.format(dep))
                return 1
            rc = subprocess.call(scp(dep, tmp))
            if rc != 0:
                sys.stderr.write('Failed to copy dependency "{}" to remote host'.format(dep))
                return rc

        # Make sure all test-executables in the remote command line have 'execute'
        # permissions on the remote host. The host that compiled the test-executable
        # might not have a notion of 'executable' permissions.
        for exe in map(testExeOnRemote, filter(isTestExe, commandLine)):
            rc = subprocess.call(ssh('chmod +x {}'.format(exe)))
            if rc != 0:
                sys.stderr.write('Failed to chmod +x test-executable "{}" on the remote host'.format(exe))
                return rc

        # Execute the command through SSH in the temporary directory, with the
        # correct environment. We tweak the command line to run it on the remote
        # host by transforming the path of test-executables to their path in the
        # temporary directory, where we know they have been copied when we handled
        # test dependencies above.
        commands = [
            'cd {}'.format(tmp),
            'export {}'.format(' '.join(args.env)),
            ' '.join(testExeOnRemote(x) if isTestExe(x) else x for x in commandLine)
        ]
        rc = subprocess.call(ssh(' && '.join(commands)))
        return rc

    finally:
        # Make sure the temporary directory is removed when we're done.
        subprocess.call(ssh('rm -r {}'.format(tmp)))


if __name__ == '__main__':
    exit(main())
