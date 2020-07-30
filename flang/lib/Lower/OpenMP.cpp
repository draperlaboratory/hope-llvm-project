//===-- OpenMP.cpp -- Open MP directive lowering --------------------------===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//
//
// Coding style: https://mlir.llvm.org/getting_started/DeveloperGuide/
//
//===----------------------------------------------------------------------===//

#include "flang/Lower/OpenMP.h"
#include "flang/Lower/Bridge.h"
#include "flang/Lower/FIRBuilder.h"
#include "flang/Lower/PFTBuilder.h"
#include "flang/Parser/parse-tree.h"
#include "mlir/Dialect/OpenMP/OpenMPDialect.h"
#include "llvm/Frontend/OpenMP/OMPConstants.h"

#define TODO() llvm_unreachable("not yet implemented")

static void genOMP(Fortran::lower::AbstractConverter &absConv,
                   Fortran::lower::pft::Evaluation &eval,
                   const Fortran::parser::OpenMPSimpleStandaloneConstruct
                       &simpleStandaloneConstruct) {
  const auto &directive =
      std::get<Fortran::parser::OmpSimpleStandaloneDirective>(
          simpleStandaloneConstruct.t);
  switch (directive.v) {
  default:
    break;
  case llvm::omp::Directive::OMPD_barrier:
    absConv.getFirOpBuilder().create<mlir::omp::BarrierOp>(
        absConv.getCurrentLocation());
    break;
  case llvm::omp::Directive::OMPD_taskwait:
    absConv.getFirOpBuilder().create<mlir::omp::TaskwaitOp>(
        absConv.getCurrentLocation());
    break;
  case llvm::omp::Directive::OMPD_taskyield:
    absConv.getFirOpBuilder().create<mlir::omp::TaskyieldOp>(
        absConv.getCurrentLocation());
    break;
  case llvm::omp::Directive::OMPD_target_enter_data:
    TODO();
  case llvm::omp::Directive::OMPD_target_exit_data:
    TODO();
  case llvm::omp::Directive::OMPD_target_update:
    TODO();
  case llvm::omp::Directive::OMPD_ordered:
    TODO();
  }
}

static void
genOMP(Fortran::lower::AbstractConverter &absConv,
       Fortran::lower::pft::Evaluation &eval,
       const Fortran::parser::OpenMPStandaloneConstruct &standaloneConstruct) {
  std::visit(
      Fortran::common::visitors{
          [&](const Fortran::parser::OpenMPSimpleStandaloneConstruct
                  &simpleStandaloneConstruct) {
            genOMP(absConv, eval, simpleStandaloneConstruct);
          },
          [&](const Fortran::parser::OpenMPFlushConstruct &flushConstruct) {
            TODO();
          },
          [&](const Fortran::parser::OpenMPCancelConstruct &cancelConstruct) {
            TODO();
          },
          [&](const Fortran::parser::OpenMPCancellationPointConstruct
                  &cancellationPointConstruct) { TODO(); },
      },
      standaloneConstruct.u);
}

static void
genOMP(Fortran::lower::AbstractConverter &absConv,
       Fortran::lower::pft::Evaluation &eval,
       const Fortran::parser::OpenMPBlockConstruct &blockConstruct) {
  const auto &blockDirective =
      std::get<Fortran::parser::OmpBeginBlockDirective>(blockConstruct.t);
  const auto &parallelDirective =
      std::get<Fortran::parser::OmpBlockDirective>(blockDirective.t);
  if (parallelDirective.v == llvm::omp::OMPD_parallel) {
    auto &firOpBuilder = absConv.getFirOpBuilder();
    auto currentLocation = absConv.getCurrentLocation();
    auto insertPt = firOpBuilder.saveInsertionPoint();
    llvm::ArrayRef<mlir::Type> argTy;
    mlir::ValueRange range;
    llvm::SmallVector<int32_t, 6> operandSegmentSizes(6 /*Size=*/,
                                                      0 /*Value=*/);
    // create and insert the operation.
    auto parallelOp = firOpBuilder.create<mlir::omp::ParallelOp>(
        currentLocation, argTy, range);
    parallelOp.setAttr(mlir::omp::ParallelOp::getOperandSegmentSizeAttr(),
                       firOpBuilder.getI32VectorAttr(operandSegmentSizes));
    parallelOp.getRegion().push_back(new Block{});
    auto &block = parallelOp.getRegion().back();
    firOpBuilder.setInsertionPointToStart(&block);
    // ensure the block is well-formed.
    firOpBuilder.create<mlir::omp::TerminatorOp>(currentLocation);
    firOpBuilder.restoreInsertionPoint(insertPt);
  }
}

void Fortran::lower::genOpenMPConstruct(
    Fortran::lower::AbstractConverter &absConv,
    Fortran::lower::pft::Evaluation &eval,
    const Fortran::parser::OpenMPConstruct &ompConstruct) {

  std::visit(
      common::visitors{
          [&](const Fortran::parser::OpenMPStandaloneConstruct
                  &standaloneConstruct) {
            genOMP(absConv, eval, standaloneConstruct);
          },
          [&](const Fortran::parser::OpenMPSectionsConstruct
                  &sectionsConstruct) { TODO(); },
          [&](const Fortran::parser::OpenMPLoopConstruct &loopConstruct) {
            TODO();
          },
          [&](const Fortran::parser::OpenMPBlockConstruct &blockConstruct) {
            genOMP(absConv, eval, blockConstruct);
          },
          [&](const Fortran::parser::OpenMPAtomicConstruct &atomicConstruct) {
            TODO();
          },
          [&](const Fortran::parser::OpenMPCriticalConstruct
                  &criticalConstruct) { TODO(); },
      },
      ompConstruct.u);
}

void Fortran::lower::genOpenMPEndLoop(
    Fortran::lower::AbstractConverter &, Fortran::lower::pft::Evaluation &,
    const Fortran::parser::OmpEndLoopDirective &) {
  TODO();
}
