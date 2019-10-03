set(LLVM_TARGET_DEFINITIONS Attributes.td)
tablegen(LLVM Attributes.inc -gen-attrs)
add_public_tablegen_target(attributes_gen)

set(LLVM_TARGET_DEFINITIONS Intrinsics.td)
tablegen(LLVM IntrinsicEnums.inc -gen-intrinsic-enums)
tablegen(LLVM IntrinsicImpl.inc -gen-intrinsic-impl)
add_public_tablegen_target(intrinsics_gen)
