//===- LangOptions.h - C Language Family Language Options -------*- C++ -*-===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//
//
/// \file
/// Defines the clang::LangOptions interface.
//
//===----------------------------------------------------------------------===//

#ifndef LLVM_CLANG_BASIC_LANGOPTIONS_H
#define LLVM_CLANG_BASIC_LANGOPTIONS_H

#include "clang/Basic/CommentOptions.h"
#include "clang/Basic/LLVM.h"
#include "clang/Basic/ObjCRuntime.h"
#include "clang/Basic/Sanitizers.h"
#include "clang/Basic/Visibility.h"
#include "llvm/ADT/FloatingPointMode.h"
#include "llvm/ADT/StringRef.h"
#include "llvm/ADT/Triple.h"
#include <string>
#include <vector>

namespace clang {

/// Bitfields of LangOptions, split out from LangOptions in order to ensure that
/// this large collection of bitfields is a trivial class type.
class LangOptionsBase {
public:
  // Define simple language options (with no accessors).
#define LANGOPT(Name, Bits, Default, Description) unsigned Name : Bits;
#define ENUM_LANGOPT(Name, Type, Bits, Default, Description)
#include "clang/Basic/LangOptions.def"

protected:
  // Define language options of enumeration type. These are private, and will
  // have accessors (below).
#define LANGOPT(Name, Bits, Default, Description)
#define ENUM_LANGOPT(Name, Type, Bits, Default, Description) \
  unsigned Name : Bits;
#include "clang/Basic/LangOptions.def"
};

/// In the Microsoft ABI, this controls the placement of virtual displacement
/// members used to implement virtual inheritance.
enum class MSVtorDispMode { Never, ForVBaseOverride, ForVFTable };

/// Keeps track of the various options that can be
/// enabled, which controls the dialect of C or C++ that is accepted.
class LangOptions : public LangOptionsBase {
public:
  using Visibility = clang::Visibility;
  using RoundingMode = llvm::RoundingMode;

  enum GCMode { NonGC, GCOnly, HybridGC };
  enum StackProtectorMode { SSPOff, SSPOn, SSPStrong, SSPReq };

  // Automatic variables live on the stack, and when trivial they're usually
  // uninitialized because it's undefined behavior to use them without
  // initializing them.
  enum class TrivialAutoVarInitKind { Uninitialized, Zero, Pattern };

  enum SignedOverflowBehaviorTy {
    // Default C standard behavior.
    SOB_Undefined,

    // -fwrapv
    SOB_Defined,

    // -ftrapv
    SOB_Trapping
  };

  // FIXME: Unify with TUKind.
  enum CompilingModuleKind {
    /// Not compiling a module interface at all.
    CMK_None,

    /// Compiling a module from a module map.
    CMK_ModuleMap,

    /// Compiling a module from a list of header files.
    CMK_HeaderModule,

    /// Compiling a C++ modules TS module interface unit.
    CMK_ModuleInterface,
  };

  enum PragmaMSPointersToMembersKind {
    PPTMK_BestCase,
    PPTMK_FullGeneralitySingleInheritance,
    PPTMK_FullGeneralityMultipleInheritance,
    PPTMK_FullGeneralityVirtualInheritance
  };

  using MSVtorDispMode = clang::MSVtorDispMode;

  enum DefaultCallingConvention {
    DCC_None,
    DCC_CDecl,
    DCC_FastCall,
    DCC_StdCall,
    DCC_VectorCall,
    DCC_RegCall
  };

  enum AddrSpaceMapMangling { ASMM_Target, ASMM_On, ASMM_Off };

  // Corresponds to _MSC_VER
  enum MSVCMajorVersion {
    MSVC2010 = 1600,
    MSVC2012 = 1700,
    MSVC2013 = 1800,
    MSVC2015 = 1900,
    MSVC2017 = 1910,
    MSVC2017_5 = 1912,
    MSVC2017_7 = 1914,
  };

  /// Clang versions with different platform ABI conformance.
  enum class ClangABI {
    /// Attempt to be ABI-compatible with code generated by Clang 3.8.x
    /// (SVN r257626). This causes <1 x long long> to be passed in an
    /// integer register instead of an SSE register on x64_64.
    Ver3_8,

    /// Attempt to be ABI-compatible with code generated by Clang 4.0.x
    /// (SVN r291814). This causes move operations to be ignored when
    /// determining whether a class type can be passed or returned directly.
    Ver4,

    /// Attempt to be ABI-compatible with code generated by Clang 6.0.x
    /// (SVN r321711). This causes determination of whether a type is
    /// standard-layout to ignore collisions between empty base classes
    /// and between base classes and member subobjects, which affects
    /// whether we reuse base class tail padding in some ABIs.
    Ver6,

    /// Attempt to be ABI-compatible with code generated by Clang 7.0.x
    /// (SVN r338536). This causes alignof (C++) and _Alignof (C11) to be
    /// compatible with __alignof (i.e., return the preferred alignment)
    /// rather than returning the required alignment.
    Ver7,

    /// Attempt to be ABI-compatible with code generated by Clang 9.0.x
    /// (SVN r351319). This causes vectors of __int128 to be passed in memory
    /// instead of passing in multiple scalar registers on x86_64 on Linux and
    /// NetBSD.
    Ver9,

    /// Conform to the underlying platform's C and C++ ABIs as closely
    /// as we can.
    Latest
  };

  enum class CoreFoundationABI {
    /// No interoperability ABI has been specified
    Unspecified,
    /// CoreFoundation does not have any language interoperability
    Standalone,
    /// Interoperability with the ObjectiveC runtime
    ObjectiveC,
    /// Interoperability with the latest known version of the Swift runtime
    Swift,
    /// Interoperability with the Swift 5.0 runtime
    Swift5_0,
    /// Interoperability with the Swift 4.2 runtime
    Swift4_2,
    /// Interoperability with the Swift 4.1 runtime
    Swift4_1,
  };

  enum FPContractModeKind {
    // Form fused FP ops only where result will not be affected.
    FPC_Off,

    // Form fused FP ops according to FP_CONTRACT rules.
    FPC_On,

    // Aggressively fuse FP ops (E.g. FMA).
    FPC_Fast
  };

  // TODO: merge FEnvAccessModeKind and FPContractModeKind
  enum FEnvAccessModeKind {
    FEA_Off,

    FEA_On
  };

  /// Alias for RoundingMode::NearestTiesToEven.
  static constexpr unsigned FPR_ToNearest =
      static_cast<unsigned>(llvm::RoundingMode::NearestTiesToEven);

  /// Possible floating point exception behavior.
  enum FPExceptionModeKind {
    /// Assume that floating-point exceptions are masked.
    FPE_Ignore,
    /// Transformations do not cause new exceptions but may hide some.
    FPE_MayTrap,
    /// Strictly preserve the floating-point exception semantics.
    FPE_Strict
  };

  enum class LaxVectorConversionKind {
    /// Permit no implicit vector bitcasts.
    None,
    /// Permit vector bitcasts between integer vectors with different numbers
    /// of elements but the same total bit-width.
    Integer,
    /// Permit vector bitcasts between all vectors with the same total
    /// bit-width.
    All,
  };

  enum class SignReturnAddressScopeKind {
    /// No signing for any function.
    None,
    /// Sign the return address of functions that spill LR.
    NonLeaf,
    /// Sign the return address of all functions,
    All
  };

  enum class SignReturnAddressKeyKind {
    /// Return address signing uses APIA key.
    AKey,
    /// Return address signing uses APIB key.
    BKey
  };

public:
  /// Set of enabled sanitizers.
  SanitizerSet Sanitize;

  /// Paths to blacklist files specifying which objects
  /// (files, functions, variables) should not be instrumented.
  std::vector<std::string> SanitizerBlacklistFiles;

  /// Paths to the XRay "always instrument" files specifying which
  /// objects (files, functions, variables) should be imbued with the XRay
  /// "always instrument" attribute.
  /// WARNING: This is a deprecated field and will go away in the future.
  std::vector<std::string> XRayAlwaysInstrumentFiles;

  /// Paths to the XRay "never instrument" files specifying which
  /// objects (files, functions, variables) should be imbued with the XRay
  /// "never instrument" attribute.
  /// WARNING: This is a deprecated field and will go away in the future.
  std::vector<std::string> XRayNeverInstrumentFiles;

  /// Paths to the XRay attribute list files, specifying which objects
  /// (files, functions, variables) should be imbued with the appropriate XRay
  /// attribute(s).
  std::vector<std::string> XRayAttrListFiles;

  clang::ObjCRuntime ObjCRuntime;

  CoreFoundationABI CFRuntime = CoreFoundationABI::Unspecified;

  std::string ObjCConstantStringClass;

  /// The name of the handler function to be called when -ftrapv is
  /// specified.
  ///
  /// If none is specified, abort (GCC-compatible behaviour).
  std::string OverflowHandler;

  /// The module currently being compiled as specified by -fmodule-name.
  std::string ModuleName;

  /// The name of the current module, of which the main source file
  /// is a part. If CompilingModule is set, we are compiling the interface
  /// of this module, otherwise we are compiling an implementation file of
  /// it. This starts as ModuleName in case -fmodule-name is provided and
  /// changes during compilation to reflect the current module.
  std::string CurrentModule;

  /// The names of any features to enable in module 'requires' decls
  /// in addition to the hard-coded list in Module.cpp and the target features.
  ///
  /// This list is sorted.
  std::vector<std::string> ModuleFeatures;

  /// Options for parsing comments.
  CommentOptions CommentOpts;

  /// A list of all -fno-builtin-* function names (e.g., memset).
  std::vector<std::string> NoBuiltinFuncs;

  /// Triples of the OpenMP targets that the host code codegen should
  /// take into account in order to generate accurate offloading descriptors.
  std::vector<llvm::Triple> OMPTargetTriples;

  /// Name of the IR file that contains the result of the OpenMP target
  /// host code generation.
  std::string OMPHostIRFile;

  /// Indicates whether the front-end is explicitly told that the
  /// input is a header file (i.e. -x c-header).
  bool IsHeaderFile = false;

  LangOptions();

  // Define accessors/mutators for language options of enumeration type.
#define LANGOPT(Name, Bits, Default, Description)
#define ENUM_LANGOPT(Name, Type, Bits, Default, Description) \
  Type get##Name() const { return static_cast<Type>(Name); } \
  void set##Name(Type Value) { Name = static_cast<unsigned>(Value); }
#include "clang/Basic/LangOptions.def"

  /// Are we compiling a module interface (.cppm or module map)?
  bool isCompilingModule() const {
    return getCompilingModule() != CMK_None;
  }

  /// Do we need to track the owning module for a local declaration?
  bool trackLocalOwningModule() const {
    return isCompilingModule() || ModulesLocalVisibility;
  }

  bool isSignedOverflowDefined() const {
    return getSignedOverflowBehavior() == SOB_Defined;
  }

  bool isSubscriptPointerArithmetic() const {
    return ObjCRuntime.isSubscriptPointerArithmetic() &&
           !ObjCSubscriptingLegacyRuntime;
  }

  bool isCompatibleWithMSVC(MSVCMajorVersion MajorVersion) const {
    return MSCompatibilityVersion >= MajorVersion * 100000U;
  }

  /// Reset all of the options that are not considered when building a
  /// module.
  void resetNonModularOptions();

  /// Is this a libc/libm function that is no longer recognized as a
  /// builtin because a -fno-builtin-* option has been specified?
  bool isNoBuiltinFunc(StringRef Name) const;

  /// True if any ObjC types may have non-trivial lifetime qualifiers.
  bool allowsNonTrivialObjCLifetimeQualifiers() const {
    return ObjCAutoRefCount || ObjCWeak;
  }

  bool assumeFunctionsAreConvergent() const {
    return ConvergentFunctions;
  }

  /// Return the OpenCL C or C++ version as a VersionTuple.
  VersionTuple getOpenCLVersionTuple() const;

  /// Check if return address signing is enabled.
  bool hasSignReturnAddress() const {
    return getSignReturnAddressScope() != SignReturnAddressScopeKind::None;
  }

  /// Check if return address signing uses AKey.
  bool isSignReturnAddressWithAKey() const {
    return getSignReturnAddressKey() == SignReturnAddressKeyKind::AKey;
  }

  /// Check if leaf functions are also signed.
  bool isSignReturnAddressScopeAll() const {
    return getSignReturnAddressScope() == SignReturnAddressScopeKind::All;
  }
};

/// Floating point control options
class FPOptions {
  using RoundingMode = llvm::RoundingMode;

public:
  FPOptions() : fp_contract(LangOptions::FPC_Off),
                fenv_access(LangOptions::FEA_Off),
                rounding(LangOptions::FPR_ToNearest),
                exceptions(LangOptions::FPE_Ignore)
        {}

  // Used for serializing.
  explicit FPOptions(unsigned I)
      : fp_contract(I & 3),
        fenv_access((I >> 2) & 1),
        rounding   ((I >> 3) & 7),
        exceptions ((I >> 6) & 3)
        {}

  explicit FPOptions(const LangOptions &LangOpts)
      : fp_contract(LangOpts.getDefaultFPContractMode()),
        fenv_access(LangOptions::FEA_Off),
        rounding(LangOptions::FPR_ToNearest),
        exceptions(LangOptions::FPE_Ignore)
        {}
  // FIXME: Use getDefaultFEnvAccessMode() when available.

  /// Return the default value of FPOptions that's used when trailing
  /// storage isn't required.
  static FPOptions defaultWithoutTrailingStorage(const LangOptions &LO);

  /// Does this FPOptions require trailing storage when stored in various
  /// AST nodes, or can it be recreated using `defaultWithoutTrailingStorage`?
  bool requiresTrailingStorage(const LangOptions &LO);

  bool allowFPContractWithinStatement() const {
    return fp_contract == LangOptions::FPC_On;
  }

  bool allowFPContractAcrossStatement() const {
    return fp_contract == LangOptions::FPC_Fast;
  }

  void setAllowFPContractWithinStatement() {
    fp_contract = LangOptions::FPC_On;
  }

  void setAllowFPContractAcrossStatement() {
    fp_contract = LangOptions::FPC_Fast;
  }

  void setDisallowFPContract() { fp_contract = LangOptions::FPC_Off; }

  bool allowFEnvAccess() const {
    return fenv_access == LangOptions::FEA_On;
  }

  void setAllowFEnvAccess() {
    fenv_access = LangOptions::FEA_On;
  }

  void setDisallowFEnvAccess() { fenv_access = LangOptions::FEA_Off; }

  RoundingMode getRoundingMode() const {
    return static_cast<RoundingMode>(rounding);
  }

  void setRoundingMode(RoundingMode RM) {
    rounding = static_cast<unsigned>(RM);
  }

  LangOptions::FPExceptionModeKind getExceptionMode() const {
    return static_cast<LangOptions::FPExceptionModeKind>(exceptions);
  }

  void setExceptionMode(LangOptions::FPExceptionModeKind EM) {
    exceptions = EM;
  }

  bool isFPConstrained() const {
    return getRoundingMode() != RoundingMode::NearestTiesToEven ||
           getExceptionMode() != LangOptions::FPE_Ignore ||
           allowFEnvAccess();
  }

  /// Used to serialize this.
  unsigned getAsOpaqueInt() const {
    return fp_contract | (fenv_access << 2) | (rounding << 3) |
           (exceptions << 6);
  }

private:
  /// Adjust BinaryOperatorBitfields::FPFeatures and
  /// CXXOperatorCallExprBitfields::FPFeatures to match the total bit-field size
  /// of these fields.
  unsigned fp_contract : 2;
  unsigned fenv_access : 1;
  unsigned rounding : 3;
  unsigned exceptions : 2;
};

/// Describes the kind of translation unit being processed.
enum TranslationUnitKind {
  /// The translation unit is a complete translation unit.
  TU_Complete,

  /// The translation unit is a prefix to a translation unit, and is
  /// not complete.
  TU_Prefix,

  /// The translation unit is a module.
  TU_Module
};

} // namespace clang

#endif // LLVM_CLANG_BASIC_LANGOPTIONS_H
