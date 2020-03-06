//===- Operation.cpp - Operation support code -----------------------------===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//

#include "mlir/IR/Operation.h"
#include "mlir/IR/BlockAndValueMapping.h"
#include "mlir/IR/Diagnostics.h"
#include "mlir/IR/Dialect.h"
#include "mlir/IR/Function.h"
#include "mlir/IR/MLIRContext.h"
#include "mlir/IR/OpDefinition.h"
#include "mlir/IR/OpImplementation.h"
#include "mlir/IR/PatternMatch.h"
#include "mlir/IR/StandardTypes.h"
#include "mlir/IR/TypeUtilities.h"
#include "llvm/Support/CommandLine.h"
#include <numeric>

using namespace mlir;

static llvm::cl::opt<bool> printOpOnDiagnostic(
    "mlir-print-op-on-diagnostic",
    llvm::cl::desc("When a diagnostic is emitted on an operation, also print "
                   "the operation as an attached note"));

OpAsmParser::~OpAsmParser() {}

//===----------------------------------------------------------------------===//
// OperationName
//===----------------------------------------------------------------------===//

/// Form the OperationName for an op with the specified string.  This either is
/// a reference to an AbstractOperation if one is known, or a uniqued Identifier
/// if not.
OperationName::OperationName(StringRef name, MLIRContext *context) {
  if (auto *op = AbstractOperation::lookup(name, context))
    representation = op;
  else
    representation = Identifier::get(name, context);
}

/// Return the name of the dialect this operation is registered to.
StringRef OperationName::getDialect() const {
  return getStringRef().split('.').first;
}

/// Return the name of this operation.  This always succeeds.
StringRef OperationName::getStringRef() const {
  if (auto *op = representation.dyn_cast<const AbstractOperation *>())
    return op->name;
  return representation.get<Identifier>().strref();
}

const AbstractOperation *OperationName::getAbstractOperation() const {
  return representation.dyn_cast<const AbstractOperation *>();
}

OperationName OperationName::getFromOpaquePointer(void *pointer) {
  return OperationName(RepresentationUnion::getFromOpaqueValue(pointer));
}

//===----------------------------------------------------------------------===//
// Operation
//===----------------------------------------------------------------------===//

/// Create a new Operation with the specific fields.
Operation *Operation::create(Location location, OperationName name,
                             ArrayRef<Type> resultTypes,
                             ArrayRef<Value> operands,
                             ArrayRef<NamedAttribute> attributes,
                             ArrayRef<Block *> successors, unsigned numRegions,
                             bool resizableOperandList) {
  return create(location, name, resultTypes, operands,
                NamedAttributeList(attributes), successors, numRegions,
                resizableOperandList);
}

/// Create a new Operation from operation state.
Operation *Operation::create(const OperationState &state) {
  return Operation::create(state.location, state.name, state.types,
                           state.operands, NamedAttributeList(state.attributes),
                           state.successors, state.regions,
                           state.resizableOperandList);
}

/// Create a new Operation with the specific fields.
Operation *Operation::create(Location location, OperationName name,
                             ArrayRef<Type> resultTypes,
                             ArrayRef<Value> operands,
                             NamedAttributeList attributes,
                             ArrayRef<Block *> successors, RegionRange regions,
                             bool resizableOperandList) {
  unsigned numRegions = regions.size();
  Operation *op = create(location, name, resultTypes, operands, attributes,
                         successors, numRegions, resizableOperandList);
  for (unsigned i = 0; i < numRegions; ++i)
    if (regions[i])
      op->getRegion(i).takeBody(*regions[i]);
  return op;
}

/// Overload of create that takes an existing NamedAttributeList to avoid
/// unnecessarily uniquing a list of attributes.
Operation *Operation::create(Location location, OperationName name,
                             ArrayRef<Type> resultTypes,
                             ArrayRef<Value> operands,
                             NamedAttributeList attributes,
                             ArrayRef<Block *> successors, unsigned numRegions,
                             bool resizableOperandList) {
  // We only need to allocate additional memory for a subset of results.
  unsigned numTrailingResults = OpResult::getNumTrailing(resultTypes.size());
  unsigned numSuccessors = successors.size();
  unsigned numOperands = operands.size();

  // Compute the byte size for the operation and the operand storage.
  auto byteSize = totalSizeToAlloc<detail::TrailingOpResult, BlockOperand,
                                   Region, detail::OperandStorage>(
      numTrailingResults, numSuccessors, numRegions,
      /*detail::OperandStorage*/ 1);
  byteSize += llvm::alignTo(detail::OperandStorage::additionalAllocSize(
                                numOperands, resizableOperandList),
                            alignof(Operation));
  void *rawMem = malloc(byteSize);

  // Create the new Operation.
  auto op = ::new (rawMem) Operation(location, name, resultTypes, numSuccessors,
                                     numRegions, attributes);

  assert((numSuccessors == 0 || !op->isKnownNonTerminator()) &&
         "unexpected successors in a non-terminator operation");

  // Initialize the trailing results.
  if (LLVM_UNLIKELY(numTrailingResults > 0)) {
    // We initialize the trailing results with their result number. This makes
    // 'getResultNumber' checks much more efficient. The main purpose for these
    // results is to give an anchor to the main operation anyways, so this is
    // purely an optimization.
    auto *trailingResultIt = op->getTrailingObjects<detail::TrailingOpResult>();
    for (unsigned i = 0; i != numTrailingResults; ++i, ++trailingResultIt)
      trailingResultIt->trailingResultNumber = i;
  }

  // Initialize the regions.
  for (unsigned i = 0; i != numRegions; ++i)
    new (&op->getRegion(i)) Region(op);

  // Initialize the operands.
  new (&op->getOperandStorage())
      detail::OperandStorage(numOperands, resizableOperandList);
  auto opOperands = op->getOpOperands();
  for (unsigned i = 0; i != numOperands; ++i)
    new (&opOperands[i]) OpOperand(op, operands[i]);

  // Initialize the successors.
  auto blockOperands = op->getBlockOperands();
  for (unsigned i = 0; i != numSuccessors; ++i)
    new (&blockOperands[i]) BlockOperand(op, successors[i]);

  return op;
}

Operation::Operation(Location location, OperationName name,
                     ArrayRef<Type> resultTypes, unsigned numSuccessors,
                     unsigned numRegions, const NamedAttributeList &attributes)
    : location(location), numSuccs(numSuccessors), numRegions(numRegions),
      hasSingleResult(false), name(name), attrs(attributes) {
  if (!resultTypes.empty()) {
    // If there is a single result it is stored in-place, otherwise use a tuple.
    hasSingleResult = resultTypes.size() == 1;
    if (hasSingleResult)
      resultType = resultTypes.front();
    else
      resultType = TupleType::get(resultTypes, location->getContext());
  }
}

// Operations are deleted through the destroy() member because they are
// allocated via malloc.
Operation::~Operation() {
  assert(block == nullptr && "operation destroyed but still in a block");

  // Explicitly run the destructors for the operands and results.
  getOperandStorage().~OperandStorage();

  // Explicitly run the destructors for the successors.
  for (auto &successor : getBlockOperands())
    successor.~BlockOperand();

  // Explicitly destroy the regions.
  for (auto &region : getRegions())
    region.~Region();
}

/// Destroy this operation or one of its subclasses.
void Operation::destroy() {
  this->~Operation();
  free(this);
}

/// Return the context this operation is associated with.
MLIRContext *Operation::getContext() { return location->getContext(); }

/// Return the dialect this operation is associated with, or nullptr if the
/// associated dialect is not registered.
Dialect *Operation::getDialect() {
  if (auto *abstractOp = getAbstractOperation())
    return &abstractOp->dialect;

  // If this operation hasn't been registered or doesn't have abstract
  // operation, try looking up the dialect name in the context.
  return getContext()->getRegisteredDialect(getName().getDialect());
}

Region *Operation::getParentRegion() {
  return block ? block->getParent() : nullptr;
}

Operation *Operation::getParentOp() {
  return block ? block->getParentOp() : nullptr;
}

/// Return true if this operation is a proper ancestor of the `other`
/// operation.
bool Operation::isProperAncestor(Operation *other) {
  while ((other = other->getParentOp()))
    if (this == other)
      return true;
  return false;
}

/// Replace any uses of 'from' with 'to' within this operation.
void Operation::replaceUsesOfWith(Value from, Value to) {
  if (from == to)
    return;
  for (auto &operand : getOpOperands())
    if (operand.get() == from)
      operand.set(to);
}

/// Replace the current operands of this operation with the ones provided in
/// 'operands'. If the operands list is not resizable, the size of 'operands'
/// must be less than or equal to the current number of operands.
void Operation::setOperands(ValueRange operands) {
  getOperandStorage().setOperands(this, operands);
}

//===----------------------------------------------------------------------===//
// Diagnostics
//===----------------------------------------------------------------------===//

/// Emit an error about fatal conditions with this operation, reporting up to
/// any diagnostic handlers that may be listening.
InFlightDiagnostic Operation::emitError(const Twine &message) {
  InFlightDiagnostic diag = mlir::emitError(getLoc(), message);
  if (printOpOnDiagnostic) {
    // Print out the operation explicitly here so that we can print the generic
    // form.
    // TODO(riverriddle) It would be nice if we could instead provide the
    // specific printing flags when adding the operation as an argument to the
    // diagnostic.
    std::string printedOp;
    {
      llvm::raw_string_ostream os(printedOp);
      print(os, OpPrintingFlags().printGenericOpForm().useLocalScope());
    }
    diag.attachNote(getLoc()) << "see current operation: " << printedOp;
  }
  return diag;
}

/// Emit a warning about this operation, reporting up to any diagnostic
/// handlers that may be listening.
InFlightDiagnostic Operation::emitWarning(const Twine &message) {
  InFlightDiagnostic diag = mlir::emitWarning(getLoc(), message);
  if (printOpOnDiagnostic)
    diag.attachNote(getLoc()) << "see current operation: " << *this;
  return diag;
}

/// Emit a remark about this operation, reporting up to any diagnostic
/// handlers that may be listening.
InFlightDiagnostic Operation::emitRemark(const Twine &message) {
  InFlightDiagnostic diag = mlir::emitRemark(getLoc(), message);
  if (printOpOnDiagnostic)
    diag.attachNote(getLoc()) << "see current operation: " << *this;
  return diag;
}

//===----------------------------------------------------------------------===//
// Operation Ordering
//===----------------------------------------------------------------------===//

constexpr unsigned Operation::kInvalidOrderIdx;
constexpr unsigned Operation::kOrderStride;

/// Given an operation 'other' that is within the same parent block, return
/// whether the current operation is before 'other' in the operation list
/// of the parent block.
/// Note: This function has an average complexity of O(1), but worst case may
/// take O(N) where N is the number of operations within the parent block.
bool Operation::isBeforeInBlock(Operation *other) {
  assert(block && "Operations without parent blocks have no order.");
  assert(other && other->block == block &&
         "Expected other operation to have the same parent block.");
  // If the order of the block is already invalid, directly recompute the
  // parent.
  if (!block->isOpOrderValid()) {
    block->recomputeOpOrder();
  } else {
    // Update the order either operation if necessary.
    updateOrderIfNecessary();
    other->updateOrderIfNecessary();
  }

  return orderIndex < other->orderIndex;
}

/// Update the order index of this operation of this operation if necessary,
/// potentially recomputing the order of the parent block.
void Operation::updateOrderIfNecessary() {
  assert(block && "expected valid parent");

  // If the order is valid for this operation there is nothing to do.
  if (hasValidOrder())
    return;
  Operation *blockFront = &block->front();
  Operation *blockBack = &block->back();

  // This method is expected to only be invoked on blocks with more than one
  // operation.
  assert(blockFront != blockBack && "expected more than one operation");

  // If the operation is at the end of the block.
  if (this == blockBack) {
    Operation *prevNode = getPrevNode();
    if (!prevNode->hasValidOrder())
      return block->recomputeOpOrder();

    // Add the stride to the previous operation.
    orderIndex = prevNode->orderIndex + kOrderStride;
    return;
  }

  // If this is the first operation try to use the next operation to compute the
  // ordering.
  if (this == blockFront) {
    Operation *nextNode = getNextNode();
    if (!nextNode->hasValidOrder())
      return block->recomputeOpOrder();
    // There is no order to give this operation.
    if (nextNode->orderIndex == 0)
      return block->recomputeOpOrder();

    // If we can't use the stride, just take the middle value left. This is safe
    // because we know there is at least one valid index to assign to.
    if (nextNode->orderIndex <= kOrderStride)
      orderIndex = (nextNode->orderIndex / 2);
    else
      orderIndex = kOrderStride;
    return;
  }

  // Otherwise, this operation is between two others. Place this operation in
  // the middle of the previous and next if possible.
  Operation *prevNode = getPrevNode(), *nextNode = getNextNode();
  if (!prevNode->hasValidOrder() || !nextNode->hasValidOrder())
    return block->recomputeOpOrder();
  unsigned prevOrder = prevNode->orderIndex, nextOrder = nextNode->orderIndex;

  // Check to see if there is a valid order between the two.
  if (prevOrder + 1 == nextOrder)
    return block->recomputeOpOrder();
  orderIndex = prevOrder + 1 + ((nextOrder - prevOrder) / 2);
}

//===----------------------------------------------------------------------===//
// ilist_traits for Operation
//===----------------------------------------------------------------------===//

auto llvm::ilist_detail::SpecificNodeAccess<
    typename llvm::ilist_detail::compute_node_options<
        ::mlir::Operation>::type>::getNodePtr(pointer N) -> node_type * {
  return NodeAccess::getNodePtr<OptionsT>(N);
}

auto llvm::ilist_detail::SpecificNodeAccess<
    typename llvm::ilist_detail::compute_node_options<
        ::mlir::Operation>::type>::getNodePtr(const_pointer N)
    -> const node_type * {
  return NodeAccess::getNodePtr<OptionsT>(N);
}

auto llvm::ilist_detail::SpecificNodeAccess<
    typename llvm::ilist_detail::compute_node_options<
        ::mlir::Operation>::type>::getValuePtr(node_type *N) -> pointer {
  return NodeAccess::getValuePtr<OptionsT>(N);
}

auto llvm::ilist_detail::SpecificNodeAccess<
    typename llvm::ilist_detail::compute_node_options<
        ::mlir::Operation>::type>::getValuePtr(const node_type *N)
    -> const_pointer {
  return NodeAccess::getValuePtr<OptionsT>(N);
}

void llvm::ilist_traits<::mlir::Operation>::deleteNode(Operation *op) {
  op->destroy();
}

Block *llvm::ilist_traits<::mlir::Operation>::getContainingBlock() {
  size_t Offset(size_t(&((Block *)nullptr->*Block::getSublistAccess(nullptr))));
  iplist<Operation> *Anchor(static_cast<iplist<Operation> *>(this));
  return reinterpret_cast<Block *>(reinterpret_cast<char *>(Anchor) - Offset);
}

/// This is a trait method invoked when a operation is added to a block.  We
/// keep the block pointer up to date.
void llvm::ilist_traits<::mlir::Operation>::addNodeToList(Operation *op) {
  assert(!op->getBlock() && "already in a operation block!");
  op->block = getContainingBlock();

  // Invalidate the order on the operation.
  op->orderIndex = Operation::kInvalidOrderIdx;
}

/// This is a trait method invoked when a operation is removed from a block.
/// We keep the block pointer up to date.
void llvm::ilist_traits<::mlir::Operation>::removeNodeFromList(Operation *op) {
  assert(op->block && "not already in a operation block!");
  op->block = nullptr;
}

/// This is a trait method invoked when a operation is moved from one block
/// to another.  We keep the block pointer up to date.
void llvm::ilist_traits<::mlir::Operation>::transferNodesFromList(
    ilist_traits<Operation> &otherList, op_iterator first, op_iterator last) {
  Block *curParent = getContainingBlock();

  // Invalidate the ordering of the parent block.
  curParent->invalidateOpOrder();

  // If we are transferring operations within the same block, the block
  // pointer doesn't need to be updated.
  if (curParent == otherList.getContainingBlock())
    return;

  // Update the 'block' member of each operation.
  for (; first != last; ++first)
    first->block = curParent;
}

/// Remove this operation (and its descendants) from its Block and delete
/// all of them.
void Operation::erase() {
  if (auto *parent = getBlock())
    parent->getOperations().erase(this);
  else
    destroy();
}

/// Unlink this operation from its current block and insert it right before
/// `existingOp` which may be in the same or another block in the same
/// function.
void Operation::moveBefore(Operation *existingOp) {
  moveBefore(existingOp->getBlock(), existingOp->getIterator());
}

/// Unlink this operation from its current basic block and insert it right
/// before `iterator` in the specified basic block.
void Operation::moveBefore(Block *block,
                           llvm::iplist<Operation>::iterator iterator) {
  block->getOperations().splice(iterator, getBlock()->getOperations(),
                                getIterator());
}

/// This drops all operand uses from this operation, which is an essential
/// step in breaking cyclic dependences between references when they are to
/// be deleted.
void Operation::dropAllReferences() {
  for (auto &op : getOpOperands())
    op.drop();

  for (auto &region : getRegions())
    region.dropAllReferences();

  for (auto &dest : getBlockOperands())
    dest.drop();
}

/// This drops all uses of any values defined by this operation or its nested
/// regions, wherever they are located.
void Operation::dropAllDefinedValueUses() {
  dropAllUses();

  for (auto &region : getRegions())
    for (auto &block : region)
      block.dropAllDefinedValueUses();
}

/// Return the number of results held by this operation.
unsigned Operation::getNumResults() {
  if (!resultType)
    return 0;
  return hasSingleResult ? 1 : resultType.cast<TupleType>().size();
}

auto Operation::getResultTypes() -> result_type_range {
  if (!resultType)
    return llvm::None;
  if (hasSingleResult)
    return resultType;
  return resultType.cast<TupleType>().getTypes();
}

void Operation::setSuccessor(Block *block, unsigned index) {
  assert(index < getNumSuccessors());
  getBlockOperands()[index].set(block);
}

/// Attempt to fold this operation using the Op's registered foldHook.
LogicalResult Operation::fold(ArrayRef<Attribute> operands,
                              SmallVectorImpl<OpFoldResult> &results) {
  // If we have a registered operation definition matching this one, use it to
  // try to constant fold the operation.
  auto *abstractOp = getAbstractOperation();
  if (abstractOp && succeeded(abstractOp->foldHook(this, operands, results)))
    return success();

  // Otherwise, fall back on the dialect hook to handle it.
  Dialect *dialect = getDialect();
  if (!dialect)
    return failure();

  SmallVector<Attribute, 8> constants;
  if (failed(dialect->constantFoldHook(this, operands, constants)))
    return failure();
  results.assign(constants.begin(), constants.end());
  return success();
}

/// Emit an error with the op name prefixed, like "'dim' op " which is
/// convenient for verifiers.
InFlightDiagnostic Operation::emitOpError(const Twine &message) {
  return emitError() << "'" << getName() << "' op " << message;
}

//===----------------------------------------------------------------------===//
// Operation Cloning
//===----------------------------------------------------------------------===//

/// Create a deep copy of this operation but keep the operation regions empty.
/// Operands are remapped using `mapper` (if present), and `mapper` is updated
/// to contain the results.
Operation *Operation::cloneWithoutRegions(BlockAndValueMapping &mapper) {
  SmallVector<Value, 8> operands;
  SmallVector<Block *, 2> successors;

  // Remap the operands.
  operands.reserve(getNumOperands());
  for (auto opValue : getOperands())
    operands.push_back(mapper.lookupOrDefault(opValue));

  // Remap the successors.
  successors.reserve(getNumSuccessors());
  for (Block *successor : getSuccessors())
    successors.push_back(mapper.lookupOrDefault(successor));

  // Create the new operation.
  auto *newOp = Operation::create(getLoc(), getName(), getResultTypes(),
                                  operands, attrs, successors, getNumRegions(),
                                  hasResizableOperandsList());

  // Remember the mapping of any results.
  for (unsigned i = 0, e = getNumResults(); i != e; ++i)
    mapper.map(getResult(i), newOp->getResult(i));

  return newOp;
}

Operation *Operation::cloneWithoutRegions() {
  BlockAndValueMapping mapper;
  return cloneWithoutRegions(mapper);
}

/// Create a deep copy of this operation, remapping any operands that use
/// values outside of the operation using the map that is provided (leaving
/// them alone if no entry is present).  Replaces references to cloned
/// sub-operations to the corresponding operation that is copied, and adds
/// those mappings to the map.
Operation *Operation::clone(BlockAndValueMapping &mapper) {
  auto *newOp = cloneWithoutRegions(mapper);

  // Clone the regions.
  for (unsigned i = 0; i != numRegions; ++i)
    getRegion(i).cloneInto(&newOp->getRegion(i), mapper);

  return newOp;
}

Operation *Operation::clone() {
  BlockAndValueMapping mapper;
  return clone(mapper);
}

//===----------------------------------------------------------------------===//
// OpState trait class.
//===----------------------------------------------------------------------===//

// The fallback for the parser is to reject the custom assembly form.
ParseResult OpState::parse(OpAsmParser &parser, OperationState &result) {
  return parser.emitError(parser.getNameLoc(), "has no custom assembly form");
}

// The fallback for the printer is to print in the generic assembly form.
void OpState::print(OpAsmPrinter &p) { p.printGenericOp(getOperation()); }

/// Emit an error about fatal conditions with this operation, reporting up to
/// any diagnostic handlers that may be listening.
InFlightDiagnostic OpState::emitError(const Twine &message) {
  return getOperation()->emitError(message);
}

/// Emit an error with the op name prefixed, like "'dim' op " which is
/// convenient for verifiers.
InFlightDiagnostic OpState::emitOpError(const Twine &message) {
  return getOperation()->emitOpError(message);
}

/// Emit a warning about this operation, reporting up to any diagnostic
/// handlers that may be listening.
InFlightDiagnostic OpState::emitWarning(const Twine &message) {
  return getOperation()->emitWarning(message);
}

/// Emit a remark about this operation, reporting up to any diagnostic
/// handlers that may be listening.
InFlightDiagnostic OpState::emitRemark(const Twine &message) {
  return getOperation()->emitRemark(message);
}

//===----------------------------------------------------------------------===//
// Op Trait implementations
//===----------------------------------------------------------------------===//

LogicalResult OpTrait::impl::verifyZeroOperands(Operation *op) {
  if (op->getNumOperands() != 0)
    return op->emitOpError() << "requires zero operands";
  return success();
}

LogicalResult OpTrait::impl::verifyOneOperand(Operation *op) {
  if (op->getNumOperands() != 1)
    return op->emitOpError() << "requires a single operand";
  return success();
}

LogicalResult OpTrait::impl::verifyNOperands(Operation *op,
                                             unsigned numOperands) {
  if (op->getNumOperands() != numOperands) {
    return op->emitOpError() << "expected " << numOperands
                             << " operands, but found " << op->getNumOperands();
  }
  return success();
}

LogicalResult OpTrait::impl::verifyAtLeastNOperands(Operation *op,
                                                    unsigned numOperands) {
  if (op->getNumOperands() < numOperands)
    return op->emitOpError()
           << "expected " << numOperands << " or more operands";
  return success();
}

/// If this is a vector type, or a tensor type, return the scalar element type
/// that it is built around, otherwise return the type unmodified.
static Type getTensorOrVectorElementType(Type type) {
  if (auto vec = type.dyn_cast<VectorType>())
    return vec.getElementType();

  // Look through tensor<vector<...>> to find the underlying element type.
  if (auto tensor = type.dyn_cast<TensorType>())
    return getTensorOrVectorElementType(tensor.getElementType());
  return type;
}

LogicalResult
OpTrait::impl::verifyOperandsAreSignlessIntegerLike(Operation *op) {
  for (auto opType : op->getOperandTypes()) {
    auto type = getTensorOrVectorElementType(opType);
    if (!type.isSignlessIntOrIndex())
      return op->emitOpError() << "requires an integer or index type";
  }
  return success();
}

LogicalResult OpTrait::impl::verifyOperandsAreFloatLike(Operation *op) {
  for (auto opType : op->getOperandTypes()) {
    auto type = getTensorOrVectorElementType(opType);
    if (!type.isa<FloatType>())
      return op->emitOpError("requires a float type");
  }
  return success();
}

LogicalResult OpTrait::impl::verifySameTypeOperands(Operation *op) {
  // Zero or one operand always have the "same" type.
  unsigned nOperands = op->getNumOperands();
  if (nOperands < 2)
    return success();

  auto type = op->getOperand(0).getType();
  for (auto opType : llvm::drop_begin(op->getOperandTypes(), 1))
    if (opType != type)
      return op->emitOpError() << "requires all operands to have the same type";
  return success();
}

LogicalResult OpTrait::impl::verifyZeroResult(Operation *op) {
  if (op->getNumResults() != 0)
    return op->emitOpError() << "requires zero results";
  return success();
}

LogicalResult OpTrait::impl::verifyOneResult(Operation *op) {
  if (op->getNumResults() != 1)
    return op->emitOpError() << "requires one result";
  return success();
}

LogicalResult OpTrait::impl::verifyNResults(Operation *op,
                                            unsigned numOperands) {
  if (op->getNumResults() != numOperands)
    return op->emitOpError() << "expected " << numOperands << " results";
  return success();
}

LogicalResult OpTrait::impl::verifyAtLeastNResults(Operation *op,
                                                   unsigned numOperands) {
  if (op->getNumResults() < numOperands)
    return op->emitOpError()
           << "expected " << numOperands << " or more results";
  return success();
}

LogicalResult OpTrait::impl::verifySameOperandsShape(Operation *op) {
  if (failed(verifyAtLeastNOperands(op, 1)))
    return failure();

  auto type = op->getOperand(0).getType();
  for (auto opType : llvm::drop_begin(op->getOperandTypes(), 1)) {
    if (failed(verifyCompatibleShape(opType, type)))
      return op->emitOpError() << "requires the same shape for all operands";
  }
  return success();
}

LogicalResult OpTrait::impl::verifySameOperandsAndResultShape(Operation *op) {
  if (failed(verifyAtLeastNOperands(op, 1)) ||
      failed(verifyAtLeastNResults(op, 1)))
    return failure();

  auto type = op->getOperand(0).getType();
  for (auto resultType : op->getResultTypes()) {
    if (failed(verifyCompatibleShape(resultType, type)))
      return op->emitOpError()
             << "requires the same shape for all operands and results";
  }
  for (auto opType : llvm::drop_begin(op->getOperandTypes(), 1)) {
    if (failed(verifyCompatibleShape(opType, type)))
      return op->emitOpError()
             << "requires the same shape for all operands and results";
  }
  return success();
}

LogicalResult OpTrait::impl::verifySameOperandsElementType(Operation *op) {
  if (failed(verifyAtLeastNOperands(op, 1)))
    return failure();
  auto elementType = getElementTypeOrSelf(op->getOperand(0));

  for (auto operand : llvm::drop_begin(op->getOperands(), 1)) {
    if (getElementTypeOrSelf(operand) != elementType)
      return op->emitOpError("requires the same element type for all operands");
  }

  return success();
}

LogicalResult
OpTrait::impl::verifySameOperandsAndResultElementType(Operation *op) {
  if (failed(verifyAtLeastNOperands(op, 1)) ||
      failed(verifyAtLeastNResults(op, 1)))
    return failure();

  auto elementType = getElementTypeOrSelf(op->getResult(0));

  // Verify result element type matches first result's element type.
  for (auto result : llvm::drop_begin(op->getResults(), 1)) {
    if (getElementTypeOrSelf(result) != elementType)
      return op->emitOpError(
          "requires the same element type for all operands and results");
  }

  // Verify operand's element type matches first result's element type.
  for (auto operand : op->getOperands()) {
    if (getElementTypeOrSelf(operand) != elementType)
      return op->emitOpError(
          "requires the same element type for all operands and results");
  }

  return success();
}

LogicalResult OpTrait::impl::verifySameOperandsAndResultType(Operation *op) {
  if (failed(verifyAtLeastNOperands(op, 1)) ||
      failed(verifyAtLeastNResults(op, 1)))
    return failure();

  auto type = op->getResult(0).getType();
  auto elementType = getElementTypeOrSelf(type);
  for (auto resultType : op->getResultTypes().drop_front(1)) {
    if (getElementTypeOrSelf(resultType) != elementType ||
        failed(verifyCompatibleShape(resultType, type)))
      return op->emitOpError()
             << "requires the same type for all operands and results";
  }
  for (auto opType : op->getOperandTypes()) {
    if (getElementTypeOrSelf(opType) != elementType ||
        failed(verifyCompatibleShape(opType, type)))
      return op->emitOpError()
             << "requires the same type for all operands and results";
  }
  return success();
}

LogicalResult OpTrait::impl::verifyIsTerminator(Operation *op) {
  Block *block = op->getBlock();
  // Verify that the operation is at the end of the respective parent block.
  if (!block || &block->back() != op)
    return op->emitOpError("must be the last operation in the parent block");
  return success();
}

static LogicalResult verifyTerminatorSuccessors(Operation *op) {
  auto *parent = op->getParentRegion();

  // Verify that the operands lines up with the BB arguments in the successor.
  for (Block *succ : op->getSuccessors())
    if (succ->getParent() != parent)
      return op->emitError("reference to block defined in another region");
  return success();
}

LogicalResult OpTrait::impl::verifyZeroSuccessor(Operation *op) {
  if (op->getNumSuccessors() != 0) {
    return op->emitOpError("requires 0 successors but found ")
           << op->getNumSuccessors();
  }
  return success();
}

LogicalResult OpTrait::impl::verifyOneSuccessor(Operation *op) {
  if (op->getNumSuccessors() != 1) {
    return op->emitOpError("requires 1 successor but found ")
           << op->getNumSuccessors();
  }
  return verifyTerminatorSuccessors(op);
}
LogicalResult OpTrait::impl::verifyNSuccessors(Operation *op,
                                               unsigned numSuccessors) {
  if (op->getNumSuccessors() != numSuccessors) {
    return op->emitOpError("requires ")
           << numSuccessors << " successors but found "
           << op->getNumSuccessors();
  }
  return verifyTerminatorSuccessors(op);
}
LogicalResult OpTrait::impl::verifyAtLeastNSuccessors(Operation *op,
                                                      unsigned numSuccessors) {
  if (op->getNumSuccessors() < numSuccessors) {
    return op->emitOpError("requires at least ")
           << numSuccessors << " successors but found "
           << op->getNumSuccessors();
  }
  return verifyTerminatorSuccessors(op);
}

LogicalResult OpTrait::impl::verifyResultsAreBoolLike(Operation *op) {
  for (auto resultType : op->getResultTypes()) {
    auto elementType = getTensorOrVectorElementType(resultType);
    bool isBoolType = elementType.isInteger(1);
    if (!isBoolType)
      return op->emitOpError() << "requires a bool result type";
  }

  return success();
}

LogicalResult OpTrait::impl::verifyResultsAreFloatLike(Operation *op) {
  for (auto resultType : op->getResultTypes())
    if (!getTensorOrVectorElementType(resultType).isa<FloatType>())
      return op->emitOpError() << "requires a floating point type";

  return success();
}

LogicalResult
OpTrait::impl::verifyResultsAreSignlessIntegerLike(Operation *op) {
  for (auto resultType : op->getResultTypes())
    if (!getTensorOrVectorElementType(resultType).isSignlessIntOrIndex())
      return op->emitOpError() << "requires an integer or index type";
  return success();
}

static LogicalResult verifyValueSizeAttr(Operation *op, StringRef attrName,
                                         bool isOperand) {
  auto sizeAttr = op->getAttrOfType<DenseIntElementsAttr>(attrName);
  if (!sizeAttr)
    return op->emitOpError("requires 1D vector attribute '") << attrName << "'";

  auto sizeAttrType = sizeAttr.getType().dyn_cast<VectorType>();
  if (!sizeAttrType || sizeAttrType.getRank() != 1)
    return op->emitOpError("requires 1D vector attribute '") << attrName << "'";

  if (llvm::any_of(sizeAttr.getIntValues(), [](const APInt &element) {
        return !element.isNonNegative();
      }))
    return op->emitOpError("'")
           << attrName << "' attribute cannot have negative elements";

  size_t totalCount = std::accumulate(
      sizeAttr.begin(), sizeAttr.end(), 0,
      [](unsigned all, APInt one) { return all + one.getZExtValue(); });

  if (isOperand && totalCount != op->getNumOperands())
    return op->emitOpError("operand count (")
           << op->getNumOperands() << ") does not match with the total size ("
           << totalCount << ") specified in attribute '" << attrName << "'";
  else if (!isOperand && totalCount != op->getNumResults())
    return op->emitOpError("result count (")
           << op->getNumResults() << ") does not match with the total size ("
           << totalCount << ") specified in attribute '" << attrName << "'";
  return success();
}

LogicalResult OpTrait::impl::verifyOperandSizeAttr(Operation *op,
                                                   StringRef attrName) {
  return verifyValueSizeAttr(op, attrName, /*isOperand=*/true);
}

LogicalResult OpTrait::impl::verifyResultSizeAttr(Operation *op,
                                                  StringRef attrName) {
  return verifyValueSizeAttr(op, attrName, /*isOperand=*/false);
}

//===----------------------------------------------------------------------===//
// SideEffect Interfaces

/// Include the definitions of the side effect interfaces.
#include "mlir/IR/SideEffectInterfaces.cpp.inc"

bool MemoryEffects::Effect::classof(const SideEffects::Effect *effect) {
  return isa<Allocate>(effect) || isa<Free>(effect) || isa<Read>(effect) ||
         isa<Write>(effect);
}

//===----------------------------------------------------------------------===//
// BinaryOp implementation
//===----------------------------------------------------------------------===//

// These functions are out-of-line implementations of the methods in BinaryOp,
// which avoids them being template instantiated/duplicated.

void impl::buildBinaryOp(Builder *builder, OperationState &result, Value lhs,
                         Value rhs) {
  assert(lhs.getType() == rhs.getType());
  result.addOperands({lhs, rhs});
  result.types.push_back(lhs.getType());
}

ParseResult impl::parseOneResultSameOperandTypeOp(OpAsmParser &parser,
                                                  OperationState &result) {
  SmallVector<OpAsmParser::OperandType, 2> ops;
  Type type;
  return failure(parser.parseOperandList(ops) ||
                 parser.parseOptionalAttrDict(result.attributes) ||
                 parser.parseColonType(type) ||
                 parser.resolveOperands(ops, type, result.operands) ||
                 parser.addTypeToList(type, result.types));
}

void impl::printOneResultOp(Operation *op, OpAsmPrinter &p) {
  assert(op->getNumResults() == 1 && "op should have one result");

  // If not all the operand and result types are the same, just use the
  // generic assembly form to avoid omitting information in printing.
  auto resultType = op->getResult(0).getType();
  if (llvm::any_of(op->getOperandTypes(),
                   [&](Type type) { return type != resultType; })) {
    p.printGenericOp(op);
    return;
  }

  p << op->getName() << ' ';
  p.printOperands(op->getOperands());
  p.printOptionalAttrDict(op->getAttrs());
  // Now we can output only one type for all operands and the result.
  p << " : " << resultType;
}

//===----------------------------------------------------------------------===//
// CastOp implementation
//===----------------------------------------------------------------------===//

void impl::buildCastOp(Builder *builder, OperationState &result, Value source,
                       Type destType) {
  result.addOperands(source);
  result.addTypes(destType);
}

ParseResult impl::parseCastOp(OpAsmParser &parser, OperationState &result) {
  OpAsmParser::OperandType srcInfo;
  Type srcType, dstType;
  return failure(parser.parseOperand(srcInfo) ||
                 parser.parseOptionalAttrDict(result.attributes) ||
                 parser.parseColonType(srcType) ||
                 parser.resolveOperand(srcInfo, srcType, result.operands) ||
                 parser.parseKeywordType("to", dstType) ||
                 parser.addTypeToList(dstType, result.types));
}

void impl::printCastOp(Operation *op, OpAsmPrinter &p) {
  p << op->getName() << ' ' << op->getOperand(0);
  p.printOptionalAttrDict(op->getAttrs());
  p << " : " << op->getOperand(0).getType() << " to "
    << op->getResult(0).getType();
}

Value impl::foldCastOp(Operation *op) {
  // Identity cast
  if (op->getOperand(0).getType() == op->getResult(0).getType())
    return op->getOperand(0);
  return nullptr;
}

//===----------------------------------------------------------------------===//
// Misc. utils
//===----------------------------------------------------------------------===//

/// Insert an operation, generated by `buildTerminatorOp`, at the end of the
/// region's only block if it does not have a terminator already. If the region
/// is empty, insert a new block first. `buildTerminatorOp` should return the
/// terminator operation to insert.
void impl::ensureRegionTerminator(
    Region &region, Location loc,
    function_ref<Operation *()> buildTerminatorOp) {
  if (region.empty())
    region.push_back(new Block);

  Block &block = region.back();
  if (!block.empty() && block.back().isKnownTerminator())
    return;

  block.push_back(buildTerminatorOp());
}
