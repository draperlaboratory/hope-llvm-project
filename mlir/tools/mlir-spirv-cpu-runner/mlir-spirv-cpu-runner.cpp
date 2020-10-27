//===- mlir-spirv-cpu-runner.cpp - MLIR SPIR-V Execution on CPU -----------===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//
//
// Main entry point to a command line utility that executes an MLIR file on the
// CPU by translating MLIR GPU module and host part to LLVM IR before
// JIT-compiling and executing.
//
//===----------------------------------------------------------------------===//

#include "mlir/Conversion/GPUToSPIRV/ConvertGPUToSPIRVPass.h"
#include "mlir/Conversion/SPIRVToLLVM/ConvertSPIRVToLLVMPass.h"
#include "mlir/Conversion/StandardToLLVM/ConvertStandardToLLVMPass.h"
#include "mlir/Dialect/GPU/Passes.h"
#include "mlir/Dialect/SPIRV/Passes.h"
#include "mlir/Dialect/SPIRV/SPIRVOps.h"
#include "mlir/ExecutionEngine/JitRunner.h"
#include "mlir/ExecutionEngine/OptUtils.h"
#include "mlir/InitAllDialects.h"
#include "mlir/Pass/Pass.h"
#include "mlir/Pass/PassManager.h"
#include "mlir/Target/LLVMIR.h"

#include "llvm/IR/LLVMContext.h"
#include "llvm/IR/Module.h"
#include "llvm/Linker/Linker.h"
#include "llvm/Support/InitLLVM.h"
#include "llvm/Support/TargetSelect.h"

using namespace mlir;

/// A utility function that builds llvm::Module from two nested MLIR modules.
///
/// module @main {
///   module @kernel {
///     // Some ops
///   }
///   // Some other ops
/// }
///
/// Each of these two modules is translated to LLVM IR module, then they are
/// linked together and returned.
static std::unique_ptr<llvm::Module>
convertMLIRModule(ModuleOp module, llvm::LLVMContext &context) {
  // Verify that there is only one nested module.
  auto modules = module.getOps<ModuleOp>();
  if (!llvm::hasSingleElement(modules)) {
    module.emitError("The module must contain exactly one nested module");
    return nullptr;
  }

  // Translate nested module and erase it.
  ModuleOp nested = *modules.begin();
  std::unique_ptr<llvm::Module> kernelModule =
      translateModuleToLLVMIR(nested, context);
  nested.erase();

  std::unique_ptr<llvm::Module> mainModule =
      translateModuleToLLVMIR(module, context);
  llvm::Linker::linkModules(*mainModule, std::move(kernelModule));
  return mainModule;
}

static LogicalResult runMLIRPasses(ModuleOp module) {
  PassManager passManager(module.getContext());
  applyPassManagerCLOptions(passManager);
  passManager.addPass(createGpuKernelOutliningPass());
  passManager.addPass(createConvertGPUToSPIRVPass());

  OpPassManager &nestedPM = passManager.nest<spirv::ModuleOp>();
  nestedPM.addPass(spirv::createLowerABIAttributesPass());
  nestedPM.addPass(spirv::createUpdateVersionCapabilityExtensionPass());
  passManager.addPass(createLowerHostCodeToLLVMPass());
  passManager.addPass(createConvertSPIRVToLLVMPass());
  return passManager.run(module);
}

int main(int argc, char **argv) {
  llvm::InitLLVM y(argc, argv);

  llvm::InitializeNativeTarget();
  llvm::InitializeNativeTargetAsmPrinter();
  mlir::initializeLLVMPasses();

  mlir::JitRunnerConfig jitRunnerConfig;
  jitRunnerConfig.mlirTransformer = &runMLIRPasses;
  jitRunnerConfig.llvmModuleBuilder = &convertMLIRModule;

  return mlir::JitRunnerMain(argc, argv, jitRunnerConfig);
}
