#===----------------------------------------------------------------------===//
#
# Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
# See https://llvm.org/LICENSE.txt for license information.
# SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
#
#===----------------------------------------------------------------------===//

import importlib
import lit.util
import os
import platform
import re
import subprocess
import sys

from libcxx.util import executeCommand

class DefaultTargetInfo(object):
    def __init__(self, full_config):
        self.full_config = full_config
        self.executor = None

    def is_windows(self):
        return sys.platform.lower().strip() == 'win32'

    def is_darwin(self):
        return sys.platform.lower().strip() == 'darwin'

    def add_cxx_compile_flags(self, flags): pass
    def add_cxx_link_flags(self, flags): pass
    def allow_cxxabi_link(self): return True
    def use_lit_shell_default(self): return False

    def add_path(self, dest_env, new_path):
        if not new_path:
            return
        if 'PATH' not in dest_env:
            dest_env['PATH'] = new_path
        else:
            split_char = ';' if self.is_windows() else ':'
            dest_env['PATH'] = '%s%s%s' % (new_path, split_char,
                                           dest_env['PATH'])


class DarwinLocalTI(DefaultTargetInfo):
    def __init__(self, full_config):
        super(DarwinLocalTI, self).__init__(full_config)

    def is_host_macosx(self):
        name = lit.util.to_string(subprocess.check_output(['sw_vers', '-productName'])).strip()
        return name == "Mac OS X"

    def get_macosx_version(self):
        assert self.is_host_macosx()
        version = lit.util.to_string(subprocess.check_output(['sw_vers', '-productVersion'])).strip()
        version = re.sub(r'([0-9]+\.[0-9]+)(\..*)?', r'\1', version)
        return version

    def get_sdk_version(self, name):
        assert self.is_host_macosx()
        cmd = ['xcrun', '--sdk', name, '--show-sdk-path']
        try:
            out = subprocess.check_output(cmd).strip()
        except OSError:
            pass

        if not out:
            self.full_config.lit_config.fatal(
                    "cannot infer sdk version with: %r" % cmd)

        return re.sub(r'.*/[^0-9]+([0-9.]+)\.sdk', r'\1', out)

    def get_platform(self):
        platform = self.full_config.get_lit_conf('platform')
        if platform:
            platform = re.sub(r'([^0-9]+)([0-9\.]*)', r'\1-\2', platform)
            name, version = tuple(platform.split('-', 1))
        else:
            name = 'macosx'
            version = None

        if version:
            return (False, name, version)

        # Infer the version, either from the SDK or the system itself.  For
        # macosx, ignore the SDK version; what matters is what's at
        # /usr/lib/libc++.dylib.
        if name == 'macosx':
            version = self.get_macosx_version()
        else:
            version = self.get_sdk_version(name)
        return (True, name, version)

    def add_cxx_compile_flags(self, flags):
        if self.full_config.use_deployment:
            _, name, _ = self.full_config.config.deployment
            cmd = ['xcrun', '--sdk', name, '--show-sdk-path']
        else:
            cmd = ['xcrun', '--show-sdk-path']
        out, err, exit_code = executeCommand(cmd)
        if exit_code != 0:
            self.full_config.lit_config.warning("Could not determine macOS SDK path! stderr was " + err)
        if exit_code == 0 and out:
            sdk_path = out.strip()
            self.full_config.lit_config.note('using SDKROOT: %r' % sdk_path)
            assert isinstance(sdk_path, str)
            flags += ["-isysroot", sdk_path]

    def add_cxx_link_flags(self, flags):
        flags += ['-lSystem']

    def allow_cxxabi_link(self):
        # Don't link libc++abi explicitly on OS X because the symbols
        # should be available in libc++ directly.
        return False


class FreeBSDLocalTI(DefaultTargetInfo):
    def __init__(self, full_config):
        super(FreeBSDLocalTI, self).__init__(full_config)

    def add_cxx_link_flags(self, flags):
        flags += ['-lc', '-lm', '-lpthread', '-lgcc_s', '-lcxxrt']


class NetBSDLocalTI(DefaultTargetInfo):
    def __init__(self, full_config):
        super(NetBSDLocalTI, self).__init__(full_config)

    def add_cxx_link_flags(self, flags):
        flags += ['-lc', '-lm', '-lpthread', '-lgcc_s', '-lc++abi',
                  '-lunwind']


class LinuxLocalTI(DefaultTargetInfo):
    def __init__(self, full_config):
        super(LinuxLocalTI, self).__init__(full_config)

    def add_cxx_compile_flags(self, flags):
        flags += ['-D__STDC_FORMAT_MACROS',
                  '-D__STDC_LIMIT_MACROS',
                  '-D__STDC_CONSTANT_MACROS']

    def add_cxx_link_flags(self, flags):
        enable_threads = ('libcpp-has-no-threads' not in
                          self.full_config.config.available_features)
        llvm_unwinder = self.full_config.get_lit_bool('llvm_unwinder', False)
        shared_libcxx = self.full_config.get_lit_bool('enable_shared', True)
        flags += ['-lm']
        if not llvm_unwinder:
            flags += ['-lgcc_s', '-lgcc']
        if enable_threads:
            flags += ['-lpthread']
            if not shared_libcxx:
                flags += ['-lrt']
        flags += ['-lc']
        if llvm_unwinder:
            flags += ['-lunwind', '-ldl']
        else:
            flags += ['-lgcc_s']
        builtins_lib = self.full_config.get_lit_conf('builtins_library')
        if builtins_lib:
            flags += [builtins_lib]
        else:
            flags += ['-lgcc']
        has_libatomic = self.full_config.get_lit_bool('has_libatomic', False)
        if has_libatomic:
            flags += ['-latomic']
        san = self.full_config.get_lit_conf('use_sanitizer', '').strip()
        if san:
            # The libraries and their order are taken from the
            # linkSanitizerRuntimeDeps function in
            # clang/lib/Driver/Tools.cpp
            flags += ['-lpthread', '-lrt', '-lm', '-ldl']

class LinuxRemoteTI(LinuxLocalTI):
    def __init__(self, full_config):
        super(LinuxRemoteTI, self).__init__(full_config)

class WindowsLocalTI(DefaultTargetInfo):
    def __init__(self, full_config):
        super(WindowsLocalTI, self).__init__(full_config)

    def use_lit_shell_default(self):
        # Default to the internal shell on Windows, as bash on Windows is
        # usually very slow.
        return True


def make_target_info(full_config):
    default = "libcxx.test.target_info.LocalTI"
    info_str = full_config.get_lit_conf('target_info', default)
    if info_str != default:
        mod_path, _, info = info_str.rpartition('.')
        mod = importlib.import_module(mod_path)
        target_info = getattr(mod, info)(full_config)
        full_config.lit_config.note("inferred target_info as: %r" % info_str)
        return target_info
    target_system = platform.system()
    if target_system == 'Darwin':  return DarwinLocalTI(full_config)
    if target_system == 'FreeBSD': return FreeBSDLocalTI(full_config)
    if target_system == 'NetBSD':  return NetBSDLocalTI(full_config)
    if target_system == 'Linux':   return LinuxLocalTI(full_config)
    if target_system == 'Windows': return WindowsLocalTI(full_config)
    return DefaultTargetInfo(full_config)
