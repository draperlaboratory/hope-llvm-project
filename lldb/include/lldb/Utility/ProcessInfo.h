//===-- ProcessInfo.h -------------------------------------------*- C++ -*-===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//

#ifndef LLDB_UTILITY_PROCESSINFO_H
#define LLDB_UTILITY_PROCESSINFO_H

// LLDB headers
#include "lldb/Utility/ArchSpec.h"
#include "lldb/Utility/Args.h"
#include "lldb/Utility/Environment.h"
#include "lldb/Utility/FileSpec.h"
#include "lldb/Utility/NameMatches.h"

#include <vector>

namespace lldb_private {

class UserIDResolver;

// ProcessInfo
//
// A base class for information for a process. This can be used to fill
// out information for a process prior to launching it, or it can be used for
// an instance of a process and can be filled in with the existing values for
// that process.
class ProcessInfo {
public:
  ProcessInfo();

  ProcessInfo(const char *name, const ArchSpec &arch, lldb::pid_t pid);

  void Clear();

  const char *GetName() const;

  llvm::StringRef GetNameAsStringRef() const;

  FileSpec &GetExecutableFile() { return m_executable; }

  void SetExecutableFile(const FileSpec &exe_file,
                         bool add_exe_file_as_first_arg);

  const FileSpec &GetExecutableFile() const { return m_executable; }

  uint32_t GetUserID() const { return m_uid; }

  uint32_t GetGroupID() const { return m_gid; }

  bool UserIDIsValid() const { return m_uid != UINT32_MAX; }

  bool GroupIDIsValid() const { return m_gid != UINT32_MAX; }

  void SetUserID(uint32_t uid) { m_uid = uid; }

  void SetGroupID(uint32_t gid) { m_gid = gid; }

  ArchSpec &GetArchitecture() { return m_arch; }

  const ArchSpec &GetArchitecture() const { return m_arch; }

  void SetArchitecture(const ArchSpec &arch) { m_arch = arch; }

  lldb::pid_t GetProcessID() const { return m_pid; }

  void SetProcessID(lldb::pid_t pid) { m_pid = pid; }

  bool ProcessIDIsValid() const { return m_pid != LLDB_INVALID_PROCESS_ID; }

  void Dump(Stream &s, Platform *platform) const;

  Args &GetArguments() { return m_arguments; }

  const Args &GetArguments() const { return m_arguments; }

  llvm::StringRef GetArg0() const;

  void SetArg0(llvm::StringRef arg);

  void SetArguments(const Args &args, bool first_arg_is_executable);

  void SetArguments(char const **argv, bool first_arg_is_executable);

  Environment &GetEnvironment() { return m_environment; }
  const Environment &GetEnvironment() const { return m_environment; }

protected:
  FileSpec m_executable;
  std::string m_arg0; // argv[0] if supported. If empty, then use m_executable.
  // Not all process plug-ins support specifying an argv[0] that differs from
  // the resolved platform executable (which is in m_executable)
  Args m_arguments; // All program arguments except argv[0]
  Environment m_environment;
  uint32_t m_uid;
  uint32_t m_gid;
  ArchSpec m_arch;
  lldb::pid_t m_pid;
};

// ProcessInstanceInfo
//
// Describes an existing process and any discoverable information that pertains
// to that process.
class ProcessInstanceInfo : public ProcessInfo {
public:
  ProcessInstanceInfo()
      : ProcessInfo(), m_euid(UINT32_MAX), m_egid(UINT32_MAX),
        m_parent_pid(LLDB_INVALID_PROCESS_ID) {}

  ProcessInstanceInfo(const char *name, const ArchSpec &arch, lldb::pid_t pid)
      : ProcessInfo(name, arch, pid), m_euid(UINT32_MAX), m_egid(UINT32_MAX),
        m_parent_pid(LLDB_INVALID_PROCESS_ID) {}

  void Clear() {
    ProcessInfo::Clear();
    m_euid = UINT32_MAX;
    m_egid = UINT32_MAX;
    m_parent_pid = LLDB_INVALID_PROCESS_ID;
  }

  uint32_t GetEffectiveUserID() const { return m_euid; }

  uint32_t GetEffectiveGroupID() const { return m_egid; }

  bool EffectiveUserIDIsValid() const { return m_euid != UINT32_MAX; }

  bool EffectiveGroupIDIsValid() const { return m_egid != UINT32_MAX; }

  void SetEffectiveUserID(uint32_t uid) { m_euid = uid; }

  void SetEffectiveGroupID(uint32_t gid) { m_egid = gid; }

  lldb::pid_t GetParentProcessID() const { return m_parent_pid; }

  void SetParentProcessID(lldb::pid_t pid) { m_parent_pid = pid; }

  bool ParentProcessIDIsValid() const {
    return m_parent_pid != LLDB_INVALID_PROCESS_ID;
  }

  void Dump(Stream &s, UserIDResolver &resolver) const;

  static void DumpTableHeader(Stream &s, bool show_args, bool verbose);

  void DumpAsTableRow(Stream &s, UserIDResolver &resolver, bool show_args,
                      bool verbose) const;

protected:
  uint32_t m_euid;
  uint32_t m_egid;
  lldb::pid_t m_parent_pid;
};

typedef std::vector<ProcessInstanceInfo> ProcessInstanceInfoList;

// ProcessInstanceInfoMatch
//
// A class to help matching one ProcessInstanceInfo to another.

class ProcessInstanceInfoMatch {
public:
  ProcessInstanceInfoMatch()
      : m_match_info(), m_name_match_type(NameMatch::Ignore),
        m_match_all_users(false) {}

  ProcessInstanceInfoMatch(const char *process_name,
                           NameMatch process_name_match_type)
      : m_match_info(), m_name_match_type(process_name_match_type),
        m_match_all_users(false) {
    m_match_info.GetExecutableFile().SetFile(process_name,
                                             FileSpec::Style::native);
  }

  ProcessInstanceInfo &GetProcessInfo() { return m_match_info; }

  const ProcessInstanceInfo &GetProcessInfo() const { return m_match_info; }

  bool GetMatchAllUsers() const { return m_match_all_users; }

  void SetMatchAllUsers(bool b) { m_match_all_users = b; }

  NameMatch GetNameMatchType() const { return m_name_match_type; }

  void SetNameMatchType(NameMatch name_match_type) {
    m_name_match_type = name_match_type;
  }

  /// Return true iff the architecture in this object matches arch_spec.
  bool ArchitectureMatches(const ArchSpec &arch_spec) const;

  /// Return true iff the process name in this object matches process_name.
  bool NameMatches(const char *process_name) const;

  /// Return true iff the process ID and parent process IDs in this object match
  /// the ones in proc_info.
  bool ProcessIDsMatch(const ProcessInstanceInfo &proc_info) const;

  /// Return true iff the (both effective and real) user and group IDs in this
  /// object match the ones in proc_info.
  bool UserIDsMatch(const ProcessInstanceInfo &proc_info) const;

  bool Matches(const ProcessInstanceInfo &proc_info) const;

  bool MatchAllProcesses() const;
  void Clear();

protected:
  ProcessInstanceInfo m_match_info;
  NameMatch m_name_match_type;
  bool m_match_all_users;
};

} // namespace lldb_private

#endif // LLDB_UTILITY_PROCESSINFO_H
