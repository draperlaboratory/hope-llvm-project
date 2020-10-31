//===-- NativeProcessFreeBSD.cpp ------------------------------------------===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//

#include "NativeProcessFreeBSD.h"

// clang-format off
#include <sys/types.h>
#include <sys/ptrace.h>
#include <sys/sysctl.h>
#include <sys/user.h>
#include <sys/wait.h>
#include <machine/elf.h>
// clang-format on

#include "Plugins/Process/POSIX/ProcessPOSIXLog.h"
#include "lldb/Host/HostProcess.h"
#include "lldb/Host/posix/ProcessLauncherPosixFork.h"
#include "lldb/Target/Process.h"
#include "lldb/Utility/State.h"
#include "llvm/Support/Errno.h"

using namespace lldb;
using namespace lldb_private;
using namespace lldb_private::process_freebsd;
using namespace llvm;

// Simple helper function to ensure flags are enabled on the given file
// descriptor.
static Status EnsureFDFlags(int fd, int flags) {
  Status error;

  int status = fcntl(fd, F_GETFL);
  if (status == -1) {
    error.SetErrorToErrno();
    return error;
  }

  if (fcntl(fd, F_SETFL, status | flags) == -1) {
    error.SetErrorToErrno();
    return error;
  }

  return error;
}

// Public Static Methods

llvm::Expected<std::unique_ptr<NativeProcessProtocol>>
NativeProcessFreeBSD::Factory::Launch(ProcessLaunchInfo &launch_info,
                                      NativeDelegate &native_delegate,
                                      MainLoop &mainloop) const {
  Log *log(ProcessPOSIXLog::GetLogIfAllCategoriesSet(POSIX_LOG_PROCESS));

  Status status;
  ::pid_t pid = ProcessLauncherPosixFork()
                    .LaunchProcess(launch_info, status)
                    .GetProcessId();
  LLDB_LOG(log, "pid = {0:x}", pid);
  if (status.Fail()) {
    LLDB_LOG(log, "failed to launch process: {0}", status);
    return status.ToError();
  }

  // Wait for the child process to trap on its call to execve.
  int wstatus;
  ::pid_t wpid = llvm::sys::RetryAfterSignal(-1, ::waitpid, pid, &wstatus, 0);
  assert(wpid == pid);
  (void)wpid;
  if (!WIFSTOPPED(wstatus)) {
    LLDB_LOG(log, "Could not sync with inferior process: wstatus={1}",
             WaitStatus::Decode(wstatus));
    return llvm::make_error<StringError>("Could not sync with inferior process",
                                         llvm::inconvertibleErrorCode());
  }
  LLDB_LOG(log, "inferior started, now in stopped state");

  ProcessInstanceInfo Info;
  if (!Host::GetProcessInfo(pid, Info)) {
    return llvm::make_error<StringError>("Cannot get process architecture",
                                         llvm::inconvertibleErrorCode());
  }

  // Set the architecture to the exe architecture.
  LLDB_LOG(log, "pid = {0:x}, detected architecture {1}", pid,
           Info.GetArchitecture().GetArchitectureName());

  std::unique_ptr<NativeProcessFreeBSD> process_up(new NativeProcessFreeBSD(
      pid, launch_info.GetPTY().ReleasePrimaryFileDescriptor(), native_delegate,
      Info.GetArchitecture(), mainloop));

  status = process_up->SetupTrace();
  if (status.Fail())
    return status.ToError();

  for (const auto &thread : process_up->m_threads)
    static_cast<NativeThreadFreeBSD &>(*thread).SetStoppedBySignal(SIGSTOP);
  process_up->SetState(StateType::eStateStopped, false);

  return std::move(process_up);
}

llvm::Expected<std::unique_ptr<NativeProcessProtocol>>
NativeProcessFreeBSD::Factory::Attach(
    lldb::pid_t pid, NativeProcessProtocol::NativeDelegate &native_delegate,
    MainLoop &mainloop) const {
  Log *log(ProcessPOSIXLog::GetLogIfAllCategoriesSet(POSIX_LOG_PROCESS));
  LLDB_LOG(log, "pid = {0:x}", pid);

  // Retrieve the architecture for the running process.
  ProcessInstanceInfo Info;
  if (!Host::GetProcessInfo(pid, Info)) {
    return llvm::make_error<StringError>("Cannot get process architecture",
                                         llvm::inconvertibleErrorCode());
  }

  std::unique_ptr<NativeProcessFreeBSD> process_up(new NativeProcessFreeBSD(
      pid, -1, native_delegate, Info.GetArchitecture(), mainloop));

  Status status = process_up->Attach();
  if (!status.Success())
    return status.ToError();

  status = process_up->SetupTrace();
  if (status.Fail())
    return status.ToError();

  return std::move(process_up);
}

// Public Instance Methods

NativeProcessFreeBSD::NativeProcessFreeBSD(::pid_t pid, int terminal_fd,
                                           NativeDelegate &delegate,
                                           const ArchSpec &arch,
                                           MainLoop &mainloop)
    : NativeProcessELF(pid, terminal_fd, delegate), m_arch(arch) {
  if (m_terminal_fd != -1) {
    Status status = EnsureFDFlags(m_terminal_fd, O_NONBLOCK);
    assert(status.Success());
  }

  Status status;
  m_sigchld_handle = mainloop.RegisterSignal(
      SIGCHLD, [this](MainLoopBase &) { SigchldHandler(); }, status);
  assert(m_sigchld_handle && status.Success());
}

// Handles all waitpid events from the inferior process.
void NativeProcessFreeBSD::MonitorCallback(lldb::pid_t pid, int signal) {
  switch (signal) {
  case SIGTRAP:
    return MonitorSIGTRAP(pid);
  case SIGSTOP:
    return MonitorSIGSTOP(pid);
  default:
    return MonitorSignal(pid, signal);
  }
}

void NativeProcessFreeBSD::MonitorExited(lldb::pid_t pid, WaitStatus status) {
  Log *log(ProcessPOSIXLog::GetLogIfAllCategoriesSet(POSIX_LOG_PROCESS));

  LLDB_LOG(log, "got exit signal({0}) , pid = {1}", status, pid);

  /* Stop Tracking All Threads attached to Process */
  m_threads.clear();

  SetExitStatus(status, true);

  // Notify delegate that our process has exited.
  SetState(StateType::eStateExited, true);
}

void NativeProcessFreeBSD::MonitorSIGSTOP(lldb::pid_t pid) {
  /* Stop all Threads attached to Process */
  for (const auto &thread : m_threads) {
    static_cast<NativeThreadFreeBSD &>(*thread).SetStoppedBySignal(SIGSTOP,
                                                                   nullptr);
  }
  SetState(StateType::eStateStopped, true);
}

void NativeProcessFreeBSD::MonitorSIGTRAP(lldb::pid_t pid) {
  Log *log(ProcessPOSIXLog::GetLogIfAllCategoriesSet(POSIX_LOG_PROCESS));
  struct ptrace_lwpinfo info;

  const auto siginfo_err = PtraceWrapper(PT_LWPINFO, pid, &info, sizeof(info));
  if (siginfo_err.Fail()) {
    LLDB_LOG(log, "PT_LWPINFO failed {0}", siginfo_err);
    return;
  }
  assert(info.pl_event == PL_EVENT_SIGNAL);

  LLDB_LOG(log, "got SIGTRAP, pid = {0}, lwpid = {1}", pid, info.pl_lwpid);
  NativeThreadFreeBSD *thread = nullptr;

  if (info.pl_flags & (PL_FLAG_BORN | PL_FLAG_EXITED)) {
    if (info.pl_flags & PL_FLAG_BORN) {
      LLDB_LOG(log, "monitoring new thread, tid = {0}", info.pl_lwpid);
      AddThread(info.pl_lwpid);
    } else /*if (info.pl_flags & PL_FLAG_EXITED)*/ {
      LLDB_LOG(log, "thread exited, tid = {0}", info.pl_lwpid);
      RemoveThread(info.pl_lwpid);
    }

    Status error =
        PtraceWrapper(PT_CONTINUE, pid, reinterpret_cast<void *>(1), 0);
    if (error.Fail())
      SetState(StateType::eStateInvalid);
    return;
  }

  if (info.pl_lwpid > 0) {
    for (const auto &t : m_threads) {
      if (t->GetID() == static_cast<lldb::tid_t>(info.pl_lwpid))
        thread = static_cast<NativeThreadFreeBSD *>(t.get());
      static_cast<NativeThreadFreeBSD *>(t.get())->SetStoppedWithNoReason();
    }
    if (!thread)
      LLDB_LOG(log, "thread not found in m_threads, pid = {0}, LWP = {1}", pid,
               info.pl_lwpid);
  }

  if (info.pl_flags & PL_FLAG_SI) {
    assert(info.pl_siginfo.si_signo == SIGTRAP);

    switch (info.pl_siginfo.si_code) {
    case TRAP_BRKPT:
      if (thread) {
        thread->SetStoppedByBreakpoint();
        FixupBreakpointPCAsNeeded(*thread);
      }
      SetState(StateType::eStateStopped, true);
      break;
    case TRAP_TRACE:
      if (thread) {
        auto &regctx = static_cast<NativeRegisterContextFreeBSD &>(
            thread->GetRegisterContext());
        uint32_t wp_index = LLDB_INVALID_INDEX32;
        Status error =
            regctx.GetWatchpointHitIndex(wp_index, LLDB_INVALID_ADDRESS);
        if (error.Fail())
          LLDB_LOG(log,
                   "received error while checking for watchpoint hits, pid = "
                   "{0}, LWP = {1}, error = {2}",
                   pid, info.pl_lwpid, error);
        if (wp_index != LLDB_INVALID_INDEX32) {
          regctx.ClearWatchpointHit(wp_index);
          thread->SetStoppedByWatchpoint(wp_index);
          SetState(StateType::eStateStopped, true);
          break;
        }

        thread->SetStoppedByTrace();
      }

      SetState(StateType::eStateStopped, true);
      break;
    }
  }
}

void NativeProcessFreeBSD::MonitorSignal(lldb::pid_t pid, int signal) {
  Log *log(ProcessPOSIXLog::GetLogIfAllCategoriesSet(POSIX_LOG_PROCESS));
  struct ptrace_lwpinfo info;

  const auto siginfo_err = PtraceWrapper(PT_LWPINFO, pid, &info, sizeof(info));
  if (siginfo_err.Fail()) {
    LLDB_LOG(log, "PT_LWPINFO failed {0}", siginfo_err);
    return;
  }
  assert(info.pl_event == PL_EVENT_SIGNAL);
  // TODO: do we need to handle !PL_FLAG_SI?
  assert(info.pl_flags & PL_FLAG_SI);
  assert(info.pl_siginfo.si_signo == signal);

  for (const auto &abs_thread : m_threads) {
    NativeThreadFreeBSD &thread =
        static_cast<NativeThreadFreeBSD &>(*abs_thread);
    assert(info.pl_lwpid >= 0);
    if (info.pl_lwpid == 0 ||
        static_cast<lldb::tid_t>(info.pl_lwpid) == thread.GetID())
      thread.SetStoppedBySignal(info.pl_siginfo.si_signo, &info.pl_siginfo);
    else
      thread.SetStoppedWithNoReason();
  }
  SetState(StateType::eStateStopped, true);
}

Status NativeProcessFreeBSD::PtraceWrapper(int req, lldb::pid_t pid, void *addr,
                                           int data, int *result) {
  Log *log(ProcessPOSIXLog::GetLogIfAllCategoriesSet(POSIX_LOG_PTRACE));
  Status error;
  int ret;

  errno = 0;
  ret =
      ptrace(req, static_cast<::pid_t>(pid), static_cast<caddr_t>(addr), data);

  if (ret == -1)
    error.SetErrorToErrno();

  if (result)
    *result = ret;

  LLDB_LOG(log, "ptrace({0}, {1}, {2}, {3})={4:x}", req, pid, addr, data, ret);

  if (error.Fail())
    LLDB_LOG(log, "ptrace() failed: {0}", error);

  return error;
}

Status NativeProcessFreeBSD::Resume(const ResumeActionList &resume_actions) {
  Log *log(ProcessPOSIXLog::GetLogIfAllCategoriesSet(POSIX_LOG_PROCESS));
  LLDB_LOG(log, "pid {0}", GetID());

  Status ret;

  int signal = 0;
  for (const auto &abs_thread : m_threads) {
    assert(abs_thread && "thread list should not contain NULL threads");
    NativeThreadFreeBSD &thread =
        static_cast<NativeThreadFreeBSD &>(*abs_thread);

    const ResumeAction *action =
        resume_actions.GetActionForThread(thread.GetID(), true);
    // we need to explicit issue suspend requests, so it is simpler to map it
    // into proper action
    ResumeAction suspend_action{thread.GetID(), eStateSuspended,
                                LLDB_INVALID_SIGNAL_NUMBER};

    if (action == nullptr) {
      LLDB_LOG(log, "no action specified for pid {0} tid {1}", GetID(),
               thread.GetID());
      action = &suspend_action;
    }

    LLDB_LOG(
        log,
        "processing resume action state {0} signal {1} for pid {2} tid {3}",
        action->state, action->signal, GetID(), thread.GetID());

    switch (action->state) {
    case eStateRunning:
      ret = thread.Resume();
      break;
    case eStateStepping:
      ret = thread.SingleStep();
      break;
    case eStateSuspended:
    case eStateStopped:
      if (action->signal != LLDB_INVALID_SIGNAL_NUMBER)
        return Status("Passing signal to suspended thread unsupported");

      ret = thread.Suspend();
      break;

    default:
      return Status(
          "NativeProcessFreeBSD::%s (): unexpected state %s specified "
          "for pid %" PRIu64 ", tid %" PRIu64,
          __FUNCTION__, StateAsCString(action->state), GetID(), thread.GetID());
    }

    if (!ret.Success())
      return ret;
    if (action->signal != LLDB_INVALID_SIGNAL_NUMBER)
      signal = action->signal;
  }

  ret =
      PtraceWrapper(PT_CONTINUE, GetID(), reinterpret_cast<void *>(1), signal);
  if (ret.Success())
    SetState(eStateRunning, true);
  return ret;
}

Status NativeProcessFreeBSD::Halt() {
  Status error;

  if (kill(GetID(), SIGSTOP) != 0)
    error.SetErrorToErrno();
  return error;
}

Status NativeProcessFreeBSD::Detach() {
  Status error;

  // Stop monitoring the inferior.
  m_sigchld_handle.reset();

  // Tell ptrace to detach from the process.
  if (GetID() == LLDB_INVALID_PROCESS_ID)
    return error;

  return PtraceWrapper(PT_DETACH, GetID());
}

Status NativeProcessFreeBSD::Signal(int signo) {
  Status error;

  if (kill(GetID(), signo))
    error.SetErrorToErrno();

  return error;
}

Status NativeProcessFreeBSD::Interrupt() { return Halt(); }

Status NativeProcessFreeBSD::Kill() {
  Log *log(ProcessPOSIXLog::GetLogIfAllCategoriesSet(POSIX_LOG_PROCESS));
  LLDB_LOG(log, "pid {0}", GetID());

  Status error;

  switch (m_state) {
  case StateType::eStateInvalid:
  case StateType::eStateExited:
  case StateType::eStateCrashed:
  case StateType::eStateDetached:
  case StateType::eStateUnloaded:
    // Nothing to do - the process is already dead.
    LLDB_LOG(log, "ignored for PID {0} due to current state: {1}", GetID(),
             StateAsCString(m_state));
    return error;

  case StateType::eStateConnected:
  case StateType::eStateAttaching:
  case StateType::eStateLaunching:
  case StateType::eStateStopped:
  case StateType::eStateRunning:
  case StateType::eStateStepping:
  case StateType::eStateSuspended:
    // We can try to kill a process in these states.
    break;
  }

  return PtraceWrapper(PT_KILL, m_pid);
}

Status NativeProcessFreeBSD::GetMemoryRegionInfo(lldb::addr_t load_addr,
                                                 MemoryRegionInfo &range_info) {

  if (m_supports_mem_region == LazyBool::eLazyBoolNo) {
    // We're done.
    return Status("unsupported");
  }

  Status error = PopulateMemoryRegionCache();
  if (error.Fail()) {
    return error;
  }

  lldb::addr_t prev_base_address = 0;
  // FIXME start by finding the last region that is <= target address using
  // binary search.  Data is sorted.
  // There can be a ton of regions on pthreads apps with lots of threads.
  for (auto it = m_mem_region_cache.begin(); it != m_mem_region_cache.end();
       ++it) {
    MemoryRegionInfo &proc_entry_info = it->first;
    // Sanity check assumption that memory map entries are ascending.
    assert((proc_entry_info.GetRange().GetRangeBase() >= prev_base_address) &&
           "descending memory map entries detected, unexpected");
    prev_base_address = proc_entry_info.GetRange().GetRangeBase();
    UNUSED_IF_ASSERT_DISABLED(prev_base_address);
    // If the target address comes before this entry, indicate distance to next
    // region.
    if (load_addr < proc_entry_info.GetRange().GetRangeBase()) {
      range_info.GetRange().SetRangeBase(load_addr);
      range_info.GetRange().SetByteSize(
          proc_entry_info.GetRange().GetRangeBase() - load_addr);
      range_info.SetReadable(MemoryRegionInfo::OptionalBool::eNo);
      range_info.SetWritable(MemoryRegionInfo::OptionalBool::eNo);
      range_info.SetExecutable(MemoryRegionInfo::OptionalBool::eNo);
      range_info.SetMapped(MemoryRegionInfo::OptionalBool::eNo);
      return error;
    } else if (proc_entry_info.GetRange().Contains(load_addr)) {
      // The target address is within the memory region we're processing here.
      range_info = proc_entry_info;
      return error;
    }
    // The target memory address comes somewhere after the region we just
    // parsed.
  }
  // If we made it here, we didn't find an entry that contained the given
  // address. Return the load_addr as start and the amount of bytes betwwen
  // load address and the end of the memory as size.
  range_info.GetRange().SetRangeBase(load_addr);
  range_info.GetRange().SetRangeEnd(LLDB_INVALID_ADDRESS);
  range_info.SetReadable(MemoryRegionInfo::OptionalBool::eNo);
  range_info.SetWritable(MemoryRegionInfo::OptionalBool::eNo);
  range_info.SetExecutable(MemoryRegionInfo::OptionalBool::eNo);
  range_info.SetMapped(MemoryRegionInfo::OptionalBool::eNo);
  return error;
}

Status NativeProcessFreeBSD::PopulateMemoryRegionCache() {
  Log *log(ProcessPOSIXLog::GetLogIfAllCategoriesSet(POSIX_LOG_PROCESS));
  // If our cache is empty, pull the latest.  There should always be at least
  // one memory region if memory region handling is supported.
  if (!m_mem_region_cache.empty()) {
    LLDB_LOG(log, "reusing {0} cached memory region entries",
             m_mem_region_cache.size());
    return Status();
  }

  int mib[4] = {CTL_KERN, KERN_PROC, KERN_PROC_VMMAP, static_cast<int>(m_pid)};
  int ret;
  size_t len;

  ret = ::sysctl(mib, 4, nullptr, &len, nullptr, 0);
  if (ret != 0) {
    m_supports_mem_region = LazyBool::eLazyBoolNo;
    return Status("sysctl() for KERN_PROC_VMMAP failed");
  }

  std::unique_ptr<WritableMemoryBuffer> buf =
      llvm::WritableMemoryBuffer::getNewMemBuffer(len);
  ret = ::sysctl(mib, 4, buf->getBufferStart(), &len, nullptr, 0);
  if (ret != 0) {
    m_supports_mem_region = LazyBool::eLazyBoolNo;
    return Status("sysctl() for KERN_PROC_VMMAP failed");
  }

  char *bp = buf->getBufferStart();
  char *end = bp + len;
  while (bp < end) {
    auto *kv = reinterpret_cast<struct kinfo_vmentry *>(bp);
    if (kv->kve_structsize == 0)
      break;
    bp += kv->kve_structsize;

    MemoryRegionInfo info;
    info.Clear();
    info.GetRange().SetRangeBase(kv->kve_start);
    info.GetRange().SetRangeEnd(kv->kve_end);
    info.SetMapped(MemoryRegionInfo::OptionalBool::eYes);

    if (kv->kve_protection & VM_PROT_READ)
      info.SetReadable(MemoryRegionInfo::OptionalBool::eYes);
    else
      info.SetReadable(MemoryRegionInfo::OptionalBool::eNo);

    if (kv->kve_protection & VM_PROT_WRITE)
      info.SetWritable(MemoryRegionInfo::OptionalBool::eYes);
    else
      info.SetWritable(MemoryRegionInfo::OptionalBool::eNo);

    if (kv->kve_protection & VM_PROT_EXECUTE)
      info.SetExecutable(MemoryRegionInfo::OptionalBool::eYes);
    else
      info.SetExecutable(MemoryRegionInfo::OptionalBool::eNo);

    if (kv->kve_path[0])
      info.SetName(kv->kve_path);

    m_mem_region_cache.emplace_back(info,
                                    FileSpec(info.GetName().GetCString()));
  }

  if (m_mem_region_cache.empty()) {
    // No entries after attempting to read them.  This shouldn't happen. Assume
    // we don't support map entries.
    LLDB_LOG(log, "failed to find any vmmap entries, assuming no support "
                  "for memory region metadata retrieval");
    m_supports_mem_region = LazyBool::eLazyBoolNo;
    return Status("not supported");
  }
  LLDB_LOG(log, "read {0} memory region entries from process {1}",
           m_mem_region_cache.size(), GetID());
  // We support memory retrieval, remember that.
  m_supports_mem_region = LazyBool::eLazyBoolYes;

  return Status();
}

lldb::addr_t NativeProcessFreeBSD::GetSharedLibraryInfoAddress() {
  // punt on this for now
  return LLDB_INVALID_ADDRESS;
}

size_t NativeProcessFreeBSD::UpdateThreads() { return m_threads.size(); }

Status NativeProcessFreeBSD::SetBreakpoint(lldb::addr_t addr, uint32_t size,
                                           bool hardware) {
  if (hardware)
    return Status("NativeProcessFreeBSD does not support hardware breakpoints");
  else
    return SetSoftwareBreakpoint(addr, size);
}

Status NativeProcessFreeBSD::GetLoadedModuleFileSpec(const char *module_path,
                                                     FileSpec &file_spec) {
  return Status("Unimplemented");
}

Status
NativeProcessFreeBSD::GetFileLoadAddress(const llvm::StringRef &file_name,
                                         lldb::addr_t &load_addr) {
  load_addr = LLDB_INVALID_ADDRESS;
  return Status();
}

void NativeProcessFreeBSD::SigchldHandler() {
  Log *log(ProcessPOSIXLog::GetLogIfAllCategoriesSet(POSIX_LOG_PROCESS));
  // Process all pending waitpid notifications.
  int status;
  ::pid_t wait_pid =
      llvm::sys::RetryAfterSignal(-1, waitpid, GetID(), &status, WNOHANG);

  if (wait_pid == 0)
    return; // We are done.

  if (wait_pid == -1) {
    Status error(errno, eErrorTypePOSIX);
    LLDB_LOG(log, "waitpid ({0}, &status, _) failed: {1}", GetID(), error);
  }

  WaitStatus wait_status = WaitStatus::Decode(status);
  bool exited = wait_status.type == WaitStatus::Exit ||
                (wait_status.type == WaitStatus::Signal &&
                 wait_pid == static_cast<::pid_t>(GetID()));

  LLDB_LOG(log,
           "waitpid ({0}, &status, _) => pid = {1}, status = {2}, exited = {3}",
           GetID(), wait_pid, status, exited);

  if (exited)
    MonitorExited(wait_pid, wait_status);
  else {
    assert(wait_status.type == WaitStatus::Stop);
    MonitorCallback(wait_pid, wait_status.status);
  }
}

bool NativeProcessFreeBSD::HasThreadNoLock(lldb::tid_t thread_id) {
  for (const auto &thread : m_threads) {
    assert(thread && "thread list should not contain NULL threads");
    if (thread->GetID() == thread_id) {
      // We have this thread.
      return true;
    }
  }

  // We don't have this thread.
  return false;
}

NativeThreadFreeBSD &NativeProcessFreeBSD::AddThread(lldb::tid_t thread_id) {
  Log *log(ProcessPOSIXLog::GetLogIfAllCategoriesSet(POSIX_LOG_THREAD));
  LLDB_LOG(log, "pid {0} adding thread with tid {1}", GetID(), thread_id);

  assert(thread_id > 0);
  assert(!HasThreadNoLock(thread_id) &&
         "attempted to add a thread by id that already exists");

  // If this is the first thread, save it as the current thread
  if (m_threads.empty())
    SetCurrentThreadID(thread_id);

  m_threads.push_back(std::make_unique<NativeThreadFreeBSD>(*this, thread_id));
  return static_cast<NativeThreadFreeBSD &>(*m_threads.back());
}

void NativeProcessFreeBSD::RemoveThread(lldb::tid_t thread_id) {
  Log *log(ProcessPOSIXLog::GetLogIfAllCategoriesSet(POSIX_LOG_THREAD));
  LLDB_LOG(log, "pid {0} removing thread with tid {1}", GetID(), thread_id);

  assert(thread_id > 0);
  assert(HasThreadNoLock(thread_id) &&
         "attempted to remove a thread that does not exist");

  for (auto it = m_threads.begin(); it != m_threads.end(); ++it) {
    if ((*it)->GetID() == thread_id) {
      m_threads.erase(it);
      break;
    }
  }
}

Status NativeProcessFreeBSD::Attach() {
  // Attach to the requested process.
  // An attach will cause the thread to stop with a SIGSTOP.
  Status status = PtraceWrapper(PT_ATTACH, m_pid);
  if (status.Fail())
    return status;

  int wstatus;
  // Need to use WALLSIG otherwise we receive an error with errno=ECHLD At this
  // point we should have a thread stopped if waitpid succeeds.
  if ((wstatus = llvm::sys::RetryAfterSignal(-1, waitpid, m_pid, nullptr, 0)) <
      0)
    return Status(errno, eErrorTypePOSIX);

  // Initialize threads and tracing status
  // NB: this needs to be called before we set thread state
  status = SetupTrace();
  if (status.Fail())
    return status;

  for (const auto &thread : m_threads)
    static_cast<NativeThreadFreeBSD &>(*thread).SetStoppedBySignal(SIGSTOP);

  // Let our process instance know the thread has stopped.
  SetCurrentThreadID(m_threads.front()->GetID());
  SetState(StateType::eStateStopped, false);
  return Status();
}

Status NativeProcessFreeBSD::ReadMemory(lldb::addr_t addr, void *buf,
                                        size_t size, size_t &bytes_read) {
  unsigned char *dst = static_cast<unsigned char *>(buf);
  struct ptrace_io_desc io;

  Log *log(ProcessPOSIXLog::GetLogIfAllCategoriesSet(POSIX_LOG_MEMORY));
  LLDB_LOG(log, "addr = {0}, buf = {1}, size = {2}", addr, buf, size);

  bytes_read = 0;
  io.piod_op = PIOD_READ_D;
  io.piod_len = size;

  do {
    io.piod_offs = (void *)(addr + bytes_read);
    io.piod_addr = dst + bytes_read;

    Status error = NativeProcessFreeBSD::PtraceWrapper(PT_IO, GetID(), &io);
    if (error.Fail() || io.piod_len == 0)
      return error;

    bytes_read += io.piod_len;
    io.piod_len = size - bytes_read;
  } while (bytes_read < size);

  return Status();
}

Status NativeProcessFreeBSD::WriteMemory(lldb::addr_t addr, const void *buf,
                                         size_t size, size_t &bytes_written) {
  const unsigned char *src = static_cast<const unsigned char *>(buf);
  Status error;
  struct ptrace_io_desc io;

  Log *log(ProcessPOSIXLog::GetLogIfAllCategoriesSet(POSIX_LOG_MEMORY));
  LLDB_LOG(log, "addr = {0}, buf = {1}, size = {2}", addr, buf, size);

  bytes_written = 0;
  io.piod_op = PIOD_WRITE_D;
  io.piod_len = size;

  do {
    io.piod_addr =
        const_cast<void *>(static_cast<const void *>(src + bytes_written));
    io.piod_offs = (void *)(addr + bytes_written);

    Status error = NativeProcessFreeBSD::PtraceWrapper(PT_IO, GetID(), &io);
    if (error.Fail() || io.piod_len == 0)
      return error;

    bytes_written += io.piod_len;
    io.piod_len = size - bytes_written;
  } while (bytes_written < size);

  return error;
}

llvm::ErrorOr<std::unique_ptr<llvm::MemoryBuffer>>
NativeProcessFreeBSD::GetAuxvData() const {
  int mib[4] = {CTL_KERN, KERN_PROC, KERN_PROC_AUXV, static_cast<int>(GetID())};
  size_t auxv_size = AT_COUNT * sizeof(Elf_Auxinfo);
  std::unique_ptr<WritableMemoryBuffer> buf =
      llvm::WritableMemoryBuffer::getNewMemBuffer(auxv_size);

  if (::sysctl(mib, 4, buf->getBufferStart(), &auxv_size, nullptr, 0) != 0)
    return std::error_code(errno, std::generic_category());

  return buf;
}

Status NativeProcessFreeBSD::SetupTrace() {
  // Enable event reporting
  int events;
  Status status =
      PtraceWrapper(PT_GET_EVENT_MASK, GetID(), &events, sizeof(events));
  if (status.Fail())
    return status;
  events |= PTRACE_LWP;
  status = PtraceWrapper(PT_SET_EVENT_MASK, GetID(), &events, sizeof(events));
  if (status.Fail())
    return status;

  return ReinitializeThreads();
}

Status NativeProcessFreeBSD::ReinitializeThreads() {
  // Clear old threads
  m_threads.clear();

  int num_lwps;
  Status error = PtraceWrapper(PT_GETNUMLWPS, GetID(), nullptr, 0, &num_lwps);
  if (error.Fail())
    return error;

  std::vector<lwpid_t> lwp_ids;
  lwp_ids.resize(num_lwps);
  error = PtraceWrapper(PT_GETLWPLIST, GetID(), lwp_ids.data(),
                        lwp_ids.size() * sizeof(lwpid_t), &num_lwps);
  if (error.Fail())
    return error;

  // Reinitialize from scratch threads and register them in process
  for (lwpid_t lwp : lwp_ids)
    AddThread(lwp);

  return error;
}
