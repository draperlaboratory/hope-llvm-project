//===-- JSONUtils.cpp -------------------------------------------*- C++ -*-===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//

#include <algorithm>

#include "llvm/ADT/Optional.h"
#include "llvm/Support/FormatAdapters.h"
#include "llvm/Support/Path.h"
#include "llvm/Support/ScopedPrinter.h"

#include "lldb/API/SBBreakpoint.h"
#include "lldb/API/SBBreakpointLocation.h"
#include "lldb/API/SBValue.h"
#include "lldb/Host/PosixApi.h"

#include "ExceptionBreakpoint.h"
#include "JSONUtils.h"
#include "LLDBUtils.h"
#include "VSCode.h"

namespace lldb_vscode {

void EmplaceSafeString(llvm::json::Object &obj, llvm::StringRef key,
                       llvm::StringRef str) {
  if (LLVM_LIKELY(llvm::json::isUTF8(str)))
    obj.try_emplace(key, str.str());
  else
    obj.try_emplace(key, llvm::json::fixUTF8(str));
}

llvm::StringRef GetAsString(const llvm::json::Value &value) {
  if (auto s = value.getAsString())
    return *s;
  return llvm::StringRef();
}

// Gets a string from a JSON object using the key, or returns an empty string.
llvm::StringRef GetString(const llvm::json::Object &obj, llvm::StringRef key) {
  if (llvm::Optional<llvm::StringRef> value = obj.getString(key))
    return *value;
  return llvm::StringRef();
}

llvm::StringRef GetString(const llvm::json::Object *obj, llvm::StringRef key) {
  if (obj == nullptr)
    return llvm::StringRef();
  return GetString(*obj, key);
}

// Gets an unsigned integer from a JSON object using the key, or returns the
// specified fail value.
uint64_t GetUnsigned(const llvm::json::Object &obj, llvm::StringRef key,
                     uint64_t fail_value) {
  if (auto value = obj.getInteger(key))
    return (uint64_t)*value;
  return fail_value;
}

uint64_t GetUnsigned(const llvm::json::Object *obj, llvm::StringRef key,
                     uint64_t fail_value) {
  if (obj == nullptr)
    return fail_value;
  return GetUnsigned(*obj, key, fail_value);
}

bool GetBoolean(const llvm::json::Object &obj, llvm::StringRef key,
                bool fail_value) {
  if (auto value = obj.getBoolean(key))
    return *value;
  if (auto value = obj.getInteger(key))
    return *value != 0;
  return fail_value;
}

bool GetBoolean(const llvm::json::Object *obj, llvm::StringRef key,
                bool fail_value) {
  if (obj == nullptr)
    return fail_value;
  return GetBoolean(*obj, key, fail_value);
}

int64_t GetSigned(const llvm::json::Object &obj, llvm::StringRef key,
                  int64_t fail_value) {
  if (auto value = obj.getInteger(key))
    return *value;
  return fail_value;
}

int64_t GetSigned(const llvm::json::Object *obj, llvm::StringRef key,
                  int64_t fail_value) {
  if (obj == nullptr)
    return fail_value;
  return GetSigned(*obj, key, fail_value);
}

bool ObjectContainsKey(const llvm::json::Object &obj, llvm::StringRef key) {
  return obj.find(key) != obj.end();
}

std::vector<std::string> GetStrings(const llvm::json::Object *obj,
                                    llvm::StringRef key) {
  std::vector<std::string> strs;
  auto json_array = obj->getArray(key);
  if (!json_array)
    return strs;
  for (const auto &value : *json_array) {
    switch (value.kind()) {
    case llvm::json::Value::String:
      strs.push_back(value.getAsString()->str());
      break;
    case llvm::json::Value::Number:
    case llvm::json::Value::Boolean:
      strs.push_back(llvm::to_string(value));
      break;
    case llvm::json::Value::Null:
    case llvm::json::Value::Object:
    case llvm::json::Value::Array:
      break;
    }
  }
  return strs;
}

void SetValueForKey(lldb::SBValue &v, llvm::json::Object &object,
                    llvm::StringRef key) {

  llvm::StringRef value = v.GetValue();
  llvm::StringRef summary = v.GetSummary();
  llvm::StringRef type_name = v.GetType().GetDisplayTypeName();

  std::string result;
  llvm::raw_string_ostream strm(result);
  if (!value.empty()) {
    strm << value;
    if (!summary.empty())
      strm << ' ' << summary;
  } else if (!summary.empty()) {
    strm << ' ' << summary;
  } else if (!type_name.empty()) {
    strm << type_name;
    lldb::addr_t address = v.GetLoadAddress();
    if (address != LLDB_INVALID_ADDRESS)
      strm << " @ " << llvm::format_hex(address, 0);
  }
  strm.flush();
  EmplaceSafeString(object, key, result);
}

void FillResponse(const llvm::json::Object &request,
                  llvm::json::Object &response) {
  // Fill in all of the needed response fields to a "request" and set "success"
  // to true by default.
  response.try_emplace("type", "response");
  response.try_emplace("seq", (int64_t)0);
  EmplaceSafeString(response, "command", GetString(request, "command"));
  const int64_t seq = GetSigned(request, "seq", 0);
  response.try_emplace("request_seq", seq);
  response.try_emplace("success", true);
}

// "Scope": {
//   "type": "object",
//   "description": "A Scope is a named container for variables. Optionally
//                   a scope can map to a source or a range within a source.",
//   "properties": {
//     "name": {
//       "type": "string",
//       "description": "Name of the scope such as 'Arguments', 'Locals'."
//     },
//     "variablesReference": {
//       "type": "integer",
//       "description": "The variables of this scope can be retrieved by
//                       passing the value of variablesReference to the
//                       VariablesRequest."
//     },
//     "namedVariables": {
//       "type": "integer",
//       "description": "The number of named variables in this scope. The
//                       client can use this optional information to present
//                       the variables in a paged UI and fetch them in chunks."
//     },
//     "indexedVariables": {
//       "type": "integer",
//       "description": "The number of indexed variables in this scope. The
//                       client can use this optional information to present
//                       the variables in a paged UI and fetch them in chunks."
//     },
//     "expensive": {
//       "type": "boolean",
//       "description": "If true, the number of variables in this scope is
//                       large or expensive to retrieve."
//     },
//     "source": {
//       "$ref": "#/definitions/Source",
//       "description": "Optional source for this scope."
//     },
//     "line": {
//       "type": "integer",
//       "description": "Optional start line of the range covered by this
//                       scope."
//     },
//     "column": {
//       "type": "integer",
//       "description": "Optional start column of the range covered by this
//                       scope."
//     },
//     "endLine": {
//       "type": "integer",
//       "description": "Optional end line of the range covered by this scope."
//     },
//     "endColumn": {
//       "type": "integer",
//       "description": "Optional end column of the range covered by this
//                       scope."
//     }
//   },
//   "required": [ "name", "variablesReference", "expensive" ]
// }
llvm::json::Value CreateScope(const llvm::StringRef name,
                              int64_t variablesReference,
                              int64_t namedVariables, bool expensive) {
  llvm::json::Object object;
  EmplaceSafeString(object, "name", name.str());
  object.try_emplace("variablesReference", variablesReference);
  object.try_emplace("expensive", expensive);
  object.try_emplace("namedVariables", namedVariables);
  return llvm::json::Value(std::move(object));
}

// "Breakpoint": {
//   "type": "object",
//   "description": "Information about a Breakpoint created in setBreakpoints
//                   or setFunctionBreakpoints.",
//   "properties": {
//     "id": {
//       "type": "integer",
//       "description": "An optional unique identifier for the breakpoint."
//     },
//     "verified": {
//       "type": "boolean",
//       "description": "If true breakpoint could be set (but not necessarily
//                       at the desired location)."
//     },
//     "message": {
//       "type": "string",
//       "description": "An optional message about the state of the breakpoint.
//                       This is shown to the user and can be used to explain
//                       why a breakpoint could not be verified."
//     },
//     "source": {
//       "$ref": "#/definitions/Source",
//       "description": "The source where the breakpoint is located."
//     },
//     "line": {
//       "type": "integer",
//       "description": "The start line of the actual range covered by the
//                       breakpoint."
//     },
//     "column": {
//       "type": "integer",
//       "description": "An optional start column of the actual range covered
//                       by the breakpoint."
//     },
//     "endLine": {
//       "type": "integer",
//       "description": "An optional end line of the actual range covered by
//                       the breakpoint."
//     },
//     "endColumn": {
//       "type": "integer",
//       "description": "An optional end column of the actual range covered by
//                       the breakpoint. If no end line is given, then the end
//                       column is assumed to be in the start line."
//     }
//   },
//   "required": [ "verified" ]
// }
llvm::json::Value CreateBreakpoint(lldb::SBBreakpoint &bp,
                                   llvm::Optional<llvm::StringRef> request_path,
                                   llvm::Optional<uint32_t> request_line) {
  // Each breakpoint location is treated as a separate breakpoint for VS code.
  // They don't have the notion of a single breakpoint with multiple locations.
  llvm::json::Object object;
  if (!bp.IsValid())
    return llvm::json::Value(std::move(object));

  object.try_emplace("verified", bp.GetNumResolvedLocations() > 0);
  object.try_emplace("id", bp.GetID());
  // VS Code DAP doesn't currently allow one breakpoint to have multiple
  // locations so we just report the first one. If we report all locations
  // then the IDE starts showing the wrong line numbers and locations for
  // other source file and line breakpoints in the same file.

  // Below we search for the first resolved location in a breakpoint and report
  // this as the breakpoint location since it will have a complete location
  // that is at least loaded in the current process.
  lldb::SBBreakpointLocation bp_loc;
  const auto num_locs = bp.GetNumLocations();
  for (size_t i = 0; i < num_locs; ++i) {
    bp_loc = bp.GetLocationAtIndex(i);
    if (bp_loc.IsResolved())
      break;
  }
  // If not locations are resolved, use the first location.
  if (!bp_loc.IsResolved())
    bp_loc = bp.GetLocationAtIndex(0);
  auto bp_addr = bp_loc.GetAddress();

  if (request_path)
    object.try_emplace("source", CreateSource(*request_path));

  if (bp_addr.IsValid()) {
    auto line_entry = bp_addr.GetLineEntry();
    const auto line = line_entry.GetLine();
    if (line != UINT32_MAX)
      object.try_emplace("line", line);
    object.try_emplace("source", CreateSource(line_entry));
  }
  // We try to add request_line as a fallback
  if (request_line)
    object.try_emplace("line", *request_line);
  return llvm::json::Value(std::move(object));
}

void AppendBreakpoint(lldb::SBBreakpoint &bp, llvm::json::Array &breakpoints,
                      llvm::Optional<llvm::StringRef> request_path,
                      llvm::Optional<uint32_t> request_line) {
  breakpoints.emplace_back(CreateBreakpoint(bp, request_path, request_line));
}

// "Event": {
//   "allOf": [ { "$ref": "#/definitions/ProtocolMessage" }, {
//     "type": "object",
//     "description": "Server-initiated event.",
//     "properties": {
//       "type": {
//         "type": "string",
//         "enum": [ "event" ]
//       },
//       "event": {
//         "type": "string",
//         "description": "Type of event."
//       },
//       "body": {
//         "type": [ "array", "boolean", "integer", "null", "number" ,
//                   "object", "string" ],
//         "description": "Event-specific information."
//       }
//     },
//     "required": [ "type", "event" ]
//   }]
// },
// "ProtocolMessage": {
//   "type": "object",
//   "description": "Base class of requests, responses, and events.",
//   "properties": {
//         "seq": {
//           "type": "integer",
//           "description": "Sequence number."
//         },
//         "type": {
//           "type": "string",
//           "description": "Message type.",
//           "_enum": [ "request", "response", "event" ]
//         }
//   },
//   "required": [ "seq", "type" ]
// }
llvm::json::Object CreateEventObject(const llvm::StringRef event_name) {
  llvm::json::Object event;
  event.try_emplace("seq", 0);
  event.try_emplace("type", "event");
  EmplaceSafeString(event, "event", event_name);
  return event;
}

// "ExceptionBreakpointsFilter": {
//   "type": "object",
//   "description": "An ExceptionBreakpointsFilter is shown in the UI as an
//                   option for configuring how exceptions are dealt with.",
//   "properties": {
//     "filter": {
//       "type": "string",
//       "description": "The internal ID of the filter. This value is passed
//                       to the setExceptionBreakpoints request."
//     },
//     "label": {
//       "type": "string",
//       "description": "The name of the filter. This will be shown in the UI."
//     },
//     "default": {
//       "type": "boolean",
//       "description": "Initial value of the filter. If not specified a value
//                       'false' is assumed."
//     }
//   },
//   "required": [ "filter", "label" ]
// }
llvm::json::Value
CreateExceptionBreakpointFilter(const ExceptionBreakpoint &bp) {
  llvm::json::Object object;
  EmplaceSafeString(object, "filter", bp.filter);
  EmplaceSafeString(object, "label", bp.label);
  object.try_emplace("default", bp.default_value);
  return llvm::json::Value(std::move(object));
}

// "Source": {
//   "type": "object",
//   "description": "A Source is a descriptor for source code. It is returned
//                   from the debug adapter as part of a StackFrame and it is
//                   used by clients when specifying breakpoints.",
//   "properties": {
//     "name": {
//       "type": "string",
//       "description": "The short name of the source. Every source returned
//                       from the debug adapter has a name. When sending a
//                       source to the debug adapter this name is optional."
//     },
//     "path": {
//       "type": "string",
//       "description": "The path of the source to be shown in the UI. It is
//                       only used to locate and load the content of the
//                       source if no sourceReference is specified (or its
//                       value is 0)."
//     },
//     "sourceReference": {
//       "type": "number",
//       "description": "If sourceReference > 0 the contents of the source must
//                       be retrieved through the SourceRequest (even if a path
//                       is specified). A sourceReference is only valid for a
//                       session, so it must not be used to persist a source."
//     },
//     "presentationHint": {
//       "type": "string",
//       "description": "An optional hint for how to present the source in the
//                       UI. A value of 'deemphasize' can be used to indicate
//                       that the source is not available or that it is
//                       skipped on stepping.",
//       "enum": [ "normal", "emphasize", "deemphasize" ]
//     },
//     "origin": {
//       "type": "string",
//       "description": "The (optional) origin of this source: possible values
//                       'internal module', 'inlined content from source map',
//                       etc."
//     },
//     "sources": {
//       "type": "array",
//       "items": {
//         "$ref": "#/definitions/Source"
//       },
//       "description": "An optional list of sources that are related to this
//                       source. These may be the source that generated this
//                       source."
//     },
//     "adapterData": {
//       "type":["array","boolean","integer","null","number","object","string"],
//       "description": "Optional data that a debug adapter might want to loop
//                       through the client. The client should leave the data
//                       intact and persist it across sessions. The client
//                       should not interpret the data."
//     },
//     "checksums": {
//       "type": "array",
//       "items": {
//         "$ref": "#/definitions/Checksum"
//       },
//       "description": "The checksums associated with this file."
//     }
//   }
// }
llvm::json::Value CreateSource(lldb::SBLineEntry &line_entry) {
  llvm::json::Object object;
  lldb::SBFileSpec file = line_entry.GetFileSpec();
  if (file.IsValid()) {
    const char *name = file.GetFilename();
    if (name)
      EmplaceSafeString(object, "name", name);
    char path[PATH_MAX] = "";
    file.GetPath(path, sizeof(path));
    if (path[0]) {
      EmplaceSafeString(object, "path", std::string(path));
    }
  }
  return llvm::json::Value(std::move(object));
}

llvm::json::Value CreateSource(llvm::StringRef source_path) {
  llvm::json::Object source;
  llvm::StringRef name = llvm::sys::path::filename(source_path);
  EmplaceSafeString(source, "name", name);
  EmplaceSafeString(source, "path", source_path);
  return llvm::json::Value(std::move(source));
}

llvm::json::Value CreateSource(lldb::SBFrame &frame, int64_t &disasm_line) {
  disasm_line = 0;
  auto line_entry = frame.GetLineEntry();
  if (line_entry.GetFileSpec().IsValid())
    return CreateSource(line_entry);

  llvm::json::Object object;
  const auto pc = frame.GetPC();

  lldb::SBInstructionList insts;
  lldb::SBFunction function = frame.GetFunction();
  lldb::addr_t low_pc = LLDB_INVALID_ADDRESS;
  if (function.IsValid()) {
    low_pc = function.GetStartAddress().GetLoadAddress(g_vsc.target);
    auto addr_srcref = g_vsc.addr_to_source_ref.find(low_pc);
    if (addr_srcref != g_vsc.addr_to_source_ref.end()) {
      // We have this disassembly cached already, return the existing
      // sourceReference
      object.try_emplace("sourceReference", addr_srcref->second);
      disasm_line = g_vsc.GetLineForPC(addr_srcref->second, pc);
    } else {
      insts = function.GetInstructions(g_vsc.target);
    }
  } else {
    lldb::SBSymbol symbol = frame.GetSymbol();
    if (symbol.IsValid()) {
      low_pc = symbol.GetStartAddress().GetLoadAddress(g_vsc.target);
      auto addr_srcref = g_vsc.addr_to_source_ref.find(low_pc);
      if (addr_srcref != g_vsc.addr_to_source_ref.end()) {
        // We have this disassembly cached already, return the existing
        // sourceReference
        object.try_emplace("sourceReference", addr_srcref->second);
        disasm_line = g_vsc.GetLineForPC(addr_srcref->second, pc);
      } else {
        insts = symbol.GetInstructions(g_vsc.target);
      }
    }
  }
  const auto num_insts = insts.GetSize();
  if (low_pc != LLDB_INVALID_ADDRESS && num_insts > 0) {
    EmplaceSafeString(object, "name", frame.GetFunctionName());
    SourceReference source;
    llvm::raw_string_ostream src_strm(source.content);
    std::string line;
    for (size_t i = 0; i < num_insts; ++i) {
      lldb::SBInstruction inst = insts.GetInstructionAtIndex(i);
      const auto inst_addr = inst.GetAddress().GetLoadAddress(g_vsc.target);
      const char *m = inst.GetMnemonic(g_vsc.target);
      const char *o = inst.GetOperands(g_vsc.target);
      const char *c = inst.GetComment(g_vsc.target);
      if (pc == inst_addr)
        disasm_line = i + 1;
      const auto inst_offset = inst_addr - low_pc;
      int spaces = 0;
      if (inst_offset < 10)
        spaces = 3;
      else if (inst_offset < 100)
        spaces = 2;
      else if (inst_offset < 1000)
        spaces = 1;
      line.clear();
      llvm::raw_string_ostream line_strm(line);
      line_strm << llvm::formatv("{0:X+}: <{1}> {2} {3,12} {4}", inst_addr,
                                 inst_offset, llvm::fmt_repeat(' ', spaces), m,
                                 o);

      // If there is a comment append it starting at column 60 or after one
      // space past the last char
      const uint32_t comment_row = std::max(line_strm.str().size(), (size_t)60);
      if (c && c[0]) {
        if (line.size() < comment_row)
          line_strm.indent(comment_row - line_strm.str().size());
        line_strm << " # " << c;
      }
      src_strm << line_strm.str() << "\n";
      source.addr_to_line[inst_addr] = i + 1;
    }
    // Flush the source stream
    src_strm.str();
    auto sourceReference = VSCode::GetNextSourceReference();
    g_vsc.source_map[sourceReference] = std::move(source);
    g_vsc.addr_to_source_ref[low_pc] = sourceReference;
    object.try_emplace("sourceReference", sourceReference);
  }
  return llvm::json::Value(std::move(object));
}

// "StackFrame": {
//   "type": "object",
//   "description": "A Stackframe contains the source location.",
//   "properties": {
//     "id": {
//       "type": "integer",
//       "description": "An identifier for the stack frame. It must be unique
//                       across all threads. This id can be used to retrieve
//                       the scopes of the frame with the 'scopesRequest' or
//                       to restart the execution of a stackframe."
//     },
//     "name": {
//       "type": "string",
//       "description": "The name of the stack frame, typically a method name."
//     },
//     "source": {
//       "$ref": "#/definitions/Source",
//       "description": "The optional source of the frame."
//     },
//     "line": {
//       "type": "integer",
//       "description": "The line within the file of the frame. If source is
//                       null or doesn't exist, line is 0 and must be ignored."
//     },
//     "column": {
//       "type": "integer",
//       "description": "The column within the line. If source is null or
//                       doesn't exist, column is 0 and must be ignored."
//     },
//     "endLine": {
//       "type": "integer",
//       "description": "An optional end line of the range covered by the
//                       stack frame."
//     },
//     "endColumn": {
//       "type": "integer",
//       "description": "An optional end column of the range covered by the
//                       stack frame."
//     },
//     "moduleId": {
//       "type": ["integer", "string"],
//       "description": "The module associated with this frame, if any."
//     },
//     "presentationHint": {
//       "type": "string",
//       "enum": [ "normal", "label", "subtle" ],
//       "description": "An optional hint for how to present this frame in
//                       the UI. A value of 'label' can be used to indicate
//                       that the frame is an artificial frame that is used
//                       as a visual label or separator. A value of 'subtle'
//                       can be used to change the appearance of a frame in
//                       a 'subtle' way."
//     }
//   },
//   "required": [ "id", "name", "line", "column" ]
// }
llvm::json::Value CreateStackFrame(lldb::SBFrame &frame) {
  llvm::json::Object object;
  int64_t frame_id = MakeVSCodeFrameID(frame);
  object.try_emplace("id", frame_id);
  EmplaceSafeString(object, "name", frame.GetFunctionName());
  int64_t disasm_line = 0;
  object.try_emplace("source", CreateSource(frame, disasm_line));

  auto line_entry = frame.GetLineEntry();
  if (disasm_line > 0) {
    object.try_emplace("line", disasm_line);
  } else {
    auto line = line_entry.GetLine();
    if (line == UINT32_MAX)
      line = 0;
    object.try_emplace("line", line);
  }
  object.try_emplace("column", line_entry.GetColumn());
  return llvm::json::Value(std::move(object));
}

// "Thread": {
//   "type": "object",
//   "description": "A Thread",
//   "properties": {
//     "id": {
//       "type": "integer",
//       "description": "Unique identifier for the thread."
//     },
//     "name": {
//       "type": "string",
//       "description": "A name of the thread."
//     }
//   },
//   "required": [ "id", "name" ]
// }
llvm::json::Value CreateThread(lldb::SBThread &thread) {
  llvm::json::Object object;
  object.try_emplace("id", (int64_t)thread.GetThreadID());
  char thread_str[64];
  snprintf(thread_str, sizeof(thread_str), "Thread #%u", thread.GetIndexID());
  const char *name = thread.GetName();
  if (name) {
    std::string thread_with_name(thread_str);
    thread_with_name += ' ';
    thread_with_name += name;
    EmplaceSafeString(object, "name", thread_with_name);
  } else {
    EmplaceSafeString(object, "name", std::string(thread_str));
  }
  return llvm::json::Value(std::move(object));
}

// "StoppedEvent": {
//   "allOf": [ { "$ref": "#/definitions/Event" }, {
//     "type": "object",
//     "description": "Event message for 'stopped' event type. The event
//                     indicates that the execution of the debuggee has stopped
//                     due to some condition. This can be caused by a break
//                     point previously set, a stepping action has completed,
//                     by executing a debugger statement etc.",
//     "properties": {
//       "event": {
//         "type": "string",
//         "enum": [ "stopped" ]
//       },
//       "body": {
//         "type": "object",
//         "properties": {
//           "reason": {
//             "type": "string",
//             "description": "The reason for the event. For backward
//                             compatibility this string is shown in the UI if
//                             the 'description' attribute is missing (but it
//                             must not be translated).",
//             "_enum": [ "step", "breakpoint", "exception", "pause", "entry" ]
//           },
//           "description": {
//             "type": "string",
//             "description": "The full reason for the event, e.g. 'Paused
//                             on exception'. This string is shown in the UI
//                             as is."
//           },
//           "threadId": {
//             "type": "integer",
//             "description": "The thread which was stopped."
//           },
//           "text": {
//             "type": "string",
//             "description": "Additional information. E.g. if reason is
//                             'exception', text contains the exception name.
//                             This string is shown in the UI."
//           },
//           "allThreadsStopped": {
//             "type": "boolean",
//             "description": "If allThreadsStopped is true, a debug adapter
//                             can announce that all threads have stopped.
//                             The client should use this information to
//                             enable that all threads can be expanded to
//                             access their stacktraces. If the attribute
//                             is missing or false, only the thread with the
//                             given threadId can be expanded."
//           }
//         },
//         "required": [ "reason" ]
//       }
//     },
//     "required": [ "event", "body" ]
//   }]
// }
llvm::json::Value CreateThreadStopped(lldb::SBThread &thread,
                                      uint32_t stop_id) {
  llvm::json::Object event(CreateEventObject("stopped"));
  llvm::json::Object body;
  switch (thread.GetStopReason()) {
  case lldb::eStopReasonTrace:
  case lldb::eStopReasonPlanComplete:
    body.try_emplace("reason", "step");
    break;
  case lldb::eStopReasonBreakpoint: {
    ExceptionBreakpoint *exc_bp = g_vsc.GetExceptionBPFromStopReason(thread);
    if (exc_bp) {
      body.try_emplace("reason", "exception");
      EmplaceSafeString(body, "description", exc_bp->label);
    } else {
      body.try_emplace("reason", "breakpoint");
      char desc_str[64];
      uint64_t bp_id = thread.GetStopReasonDataAtIndex(0);
      uint64_t bp_loc_id = thread.GetStopReasonDataAtIndex(1);
      snprintf(desc_str, sizeof(desc_str), "breakpoint %" PRIu64 ".%" PRIu64,
               bp_id, bp_loc_id);
      EmplaceSafeString(body, "description", desc_str);
    }
  } break;
  case lldb::eStopReasonWatchpoint:
  case lldb::eStopReasonInstrumentation:
    body.try_emplace("reason", "breakpoint");
    break;
  case lldb::eStopReasonSignal:
    body.try_emplace("reason", "exception");
    break;
  case lldb::eStopReasonException:
    body.try_emplace("reason", "exception");
    break;
  case lldb::eStopReasonExec:
    body.try_emplace("reason", "entry");
    break;
  case lldb::eStopReasonThreadExiting:
  case lldb::eStopReasonInvalid:
  case lldb::eStopReasonNone:
    break;
  }
  if (stop_id == 0)
    body.try_emplace("reason", "entry");
  const lldb::tid_t tid = thread.GetThreadID();
  body.try_emplace("threadId", (int64_t)tid);
  // If no description has been set, then set it to the default thread stopped
  // description. If we have breakpoints that get hit and shouldn't be reported
  // as breakpoints, then they will set the description above.
  if (ObjectContainsKey(body, "description")) {
    char description[1024];
    if (thread.GetStopDescription(description, sizeof(description))) {
      EmplaceSafeString(body, "description", std::string(description));
    }
  }
  if (tid == g_vsc.focus_tid) {
    body.try_emplace("threadCausedFocus", true);
  }
  body.try_emplace("preserveFocusHint", tid != g_vsc.focus_tid);
  body.try_emplace("allThreadsStopped", true);
  event.try_emplace("body", std::move(body));
  return llvm::json::Value(std::move(event));
}

// "Variable": {
//   "type": "object",
//   "description": "A Variable is a name/value pair. Optionally a variable
//                   can have a 'type' that is shown if space permits or when
//                   hovering over the variable's name. An optional 'kind' is
//                   used to render additional properties of the variable,
//                   e.g. different icons can be used to indicate that a
//                   variable is public or private. If the value is
//                   structured (has children), a handle is provided to
//                   retrieve the children with the VariablesRequest. If
//                   the number of named or indexed children is large, the
//                   numbers should be returned via the optional
//                   'namedVariables' and 'indexedVariables' attributes. The
//                   client can use this optional information to present the
//                   children in a paged UI and fetch them in chunks.",
//   "properties": {
//     "name": {
//       "type": "string",
//       "description": "The variable's name."
//     },
//     "value": {
//       "type": "string",
//       "description": "The variable's value. This can be a multi-line text,
//                       e.g. for a function the body of a function."
//     },
//     "type": {
//       "type": "string",
//       "description": "The type of the variable's value. Typically shown in
//                       the UI when hovering over the value."
//     },
//     "presentationHint": {
//       "$ref": "#/definitions/VariablePresentationHint",
//       "description": "Properties of a variable that can be used to determine
//                       how to render the variable in the UI."
//     },
//     "evaluateName": {
//       "type": "string",
//       "description": "Optional evaluatable name of this variable which can
//                       be passed to the 'EvaluateRequest' to fetch the
//                       variable's value."
//     },
//     "variablesReference": {
//       "type": "integer",
//       "description": "If variablesReference is > 0, the variable is
//                       structured and its children can be retrieved by
//                       passing variablesReference to the VariablesRequest."
//     },
//     "namedVariables": {
//       "type": "integer",
//       "description": "The number of named child variables. The client can
//                       use this optional information to present the children
//                       in a paged UI and fetch them in chunks."
//     },
//     "indexedVariables": {
//       "type": "integer",
//       "description": "The number of indexed child variables. The client
//                       can use this optional information to present the
//                       children in a paged UI and fetch them in chunks."
//     }
//   },
//   "required": [ "name", "value", "variablesReference" ]
// }
llvm::json::Value CreateVariable(lldb::SBValue v, int64_t variablesReference,
                                 int64_t varID, bool format_hex) {
  llvm::json::Object object;
  auto name = v.GetName();
  EmplaceSafeString(object, "name", name ? name : "<null>");
  if (format_hex)
    v.SetFormat(lldb::eFormatHex);
  SetValueForKey(v, object, "value");
  auto type_cstr = v.GetType().GetDisplayTypeName();
  EmplaceSafeString(object, "type", type_cstr ? type_cstr : NO_TYPENAME);
  if (varID != INT64_MAX)
    object.try_emplace("id", varID);
  if (v.MightHaveChildren())
    object.try_emplace("variablesReference", variablesReference);
  else
    object.try_emplace("variablesReference", (int64_t)0);
  lldb::SBStream evaluateStream;
  v.GetExpressionPath(evaluateStream);
  const char *evaluateName = evaluateStream.GetData();
  if (evaluateName && evaluateName[0])
    EmplaceSafeString(object, "evaluateName", std::string(evaluateName));
  return llvm::json::Value(std::move(object));
}

} // namespace lldb_vscode
