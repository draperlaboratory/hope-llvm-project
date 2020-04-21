// RUN: mlir-opt -test-all-reduce-lowering %s | FileCheck %s

// NOTE: Assertions have been autogenerated by utils/generate-test-checks.py
// CHECK: module @kernels attributes {gpu.kernel_module} {
module @kernels attributes {gpu.kernel_module} {

  // CHECK-LABEL: gpu.func @kernel(
  // CHECK-SAME: [[VAL_0:%.*]]: f32) workgroup([[VAL_1:%.*]] : memref<32xf32, 3>) kernel {
  gpu.func @kernel(%arg0 : f32) kernel {
    // CHECK:   [[VAL_2:%.*]] = constant 31 : i32
    // CHECK:   [[VAL_3:%.*]] = constant 0 : i32
    // CHECK:   [[VAL_4:%.*]] = constant 0 : index
    // CHECK:   [[VAL_5:%.*]] = constant 32 : i32
    // CHECK:   [[VAL_6:%.*]] = constant 1 : i32
    // CHECK:   [[VAL_7:%.*]] = constant 2 : i32
    // CHECK:   [[VAL_8:%.*]] = constant 4 : i32
    // CHECK:   [[VAL_9:%.*]] = constant 8 : i32
    // CHECK:   [[VAL_10:%.*]] = constant 16 : i32
    // CHECK:   [[VAL_11:%.*]] = "gpu.block_dim"() {dimension = "x"} : () -> index
    // CHECK:   [[VAL_12:%.*]] = index_cast [[VAL_11]] : index to i32
    // CHECK:   [[VAL_13:%.*]] = "gpu.block_dim"() {dimension = "y"} : () -> index
    // CHECK:   [[VAL_14:%.*]] = index_cast [[VAL_13]] : index to i32
    // CHECK:   [[VAL_15:%.*]] = "gpu.block_dim"() {dimension = "z"} : () -> index
    // CHECK:   [[VAL_16:%.*]] = index_cast [[VAL_15]] : index to i32
    // CHECK:   [[VAL_17:%.*]] = "gpu.thread_id"() {dimension = "x"} : () -> index
    // CHECK:   [[VAL_18:%.*]] = index_cast [[VAL_17]] : index to i32
    // CHECK:   [[VAL_19:%.*]] = "gpu.thread_id"() {dimension = "y"} : () -> index
    // CHECK:   [[VAL_20:%.*]] = index_cast [[VAL_19]] : index to i32
    // CHECK:   [[VAL_21:%.*]] = "gpu.thread_id"() {dimension = "z"} : () -> index
    // CHECK:   [[VAL_22:%.*]] = index_cast [[VAL_21]] : index to i32
    // CHECK:   [[VAL_23:%.*]] = muli [[VAL_22]], [[VAL_14]] : i32
    // CHECK:   [[VAL_24:%.*]] = addi [[VAL_23]], [[VAL_20]] : i32
    // CHECK:   [[VAL_25:%.*]] = muli [[VAL_24]], [[VAL_12]] : i32
    // CHECK:   [[VAL_26:%.*]] = muli [[VAL_12]], [[VAL_14]] : i32
    // CHECK:   [[VAL_27:%.*]] = addi [[VAL_25]], [[VAL_18]] : i32
    // CHECK:   [[VAL_28:%.*]] = muli [[VAL_26]], [[VAL_16]] : i32
    // CHECK:   [[VAL_29:%.*]] = and [[VAL_27]], [[VAL_2]] : i32
    // CHECK:   [[VAL_30:%.*]] = cmpi "eq", [[VAL_29]], [[VAL_3]] : i32
    // CHECK:   [[VAL_31:%.*]] = subi [[VAL_27]], [[VAL_29]] : i32
    // CHECK:   [[VAL_32:%.*]] = subi [[VAL_28]], [[VAL_31]] : i32
    // CHECK:   [[VAL_33:%.*]] = cmpi "slt", [[VAL_32]], [[VAL_5]] : i32
    // CHECK:   cond_br [[VAL_33]], ^bb1, ^bb17
    // CHECK: ^bb1:
    // CHECK:   [[VAL_34:%.*]], [[VAL_35:%.*]] = gpu.shuffle [[VAL_0]], [[VAL_6]], [[VAL_32]] xor : f32
    // CHECK:   cond_br [[VAL_35]], ^bb2, ^bb3
    // CHECK: ^bb2:
    // CHECK:   [[VAL_36:%.*]] = addf [[VAL_0]], [[VAL_34]] : f32
    // CHECK:   br ^bb4([[VAL_36]] : f32)
    // CHECK: ^bb3:
    // CHECK:   br ^bb4([[VAL_0]] : f32)
    // CHECK: ^bb4([[VAL_37:%.*]]: f32):
    // CHECK:   [[VAL_38:%.*]], [[VAL_39:%.*]] = gpu.shuffle [[VAL_37]], [[VAL_7]], [[VAL_32]] xor : f32
    // CHECK:   cond_br [[VAL_39]], ^bb5, ^bb6
    // CHECK: ^bb5:
    // CHECK:   [[VAL_40:%.*]] = addf [[VAL_37]], [[VAL_38]] : f32
    // CHECK:   br ^bb7([[VAL_40]] : f32)
    // CHECK: ^bb6:
    // CHECK:   br ^bb7([[VAL_37]] : f32)
    // CHECK: ^bb7([[VAL_41:%.*]]: f32):
    // CHECK:   [[VAL_42:%.*]], [[VAL_43:%.*]] = gpu.shuffle [[VAL_41]], [[VAL_8]], [[VAL_32]] xor : f32
    // CHECK:   cond_br [[VAL_43]], ^bb8, ^bb9
    // CHECK: ^bb8:
    // CHECK:   [[VAL_44:%.*]] = addf [[VAL_41]], [[VAL_42]] : f32
    // CHECK:   br ^bb10([[VAL_44]] : f32)
    // CHECK: ^bb9:
    // CHECK:   br ^bb10([[VAL_41]] : f32)
    // CHECK: ^bb10([[VAL_45:%.*]]: f32):
    // CHECK:   [[VAL_46:%.*]], [[VAL_47:%.*]] = gpu.shuffle [[VAL_45]], [[VAL_9]], [[VAL_32]] xor : f32
    // CHECK:   cond_br [[VAL_47]], ^bb11, ^bb12
    // CHECK: ^bb11:
    // CHECK:   [[VAL_48:%.*]] = addf [[VAL_45]], [[VAL_46]] : f32
    // CHECK:   br ^bb13([[VAL_48]] : f32)
    // CHECK: ^bb12:
    // CHECK:   br ^bb13([[VAL_45]] : f32)
    // CHECK: ^bb13([[VAL_49:%.*]]: f32):
    // CHECK:   [[VAL_50:%.*]], [[VAL_51:%.*]] = gpu.shuffle [[VAL_49]], [[VAL_10]], [[VAL_32]] xor : f32
    // CHECK:   cond_br [[VAL_51]], ^bb14, ^bb15
    // CHECK: ^bb14:
    // CHECK:   [[VAL_52:%.*]] = addf [[VAL_49]], [[VAL_50]] : f32
    // CHECK:   br ^bb16([[VAL_52]] : f32)
    // CHECK: ^bb15:
    // CHECK:   br ^bb16([[VAL_49]] : f32)
    // CHECK: ^bb16([[VAL_53:%.*]]: f32):
    // CHECK:   br ^bb18([[VAL_53]] : f32)
    // CHECK: ^bb17:
    // CHECK:   [[VAL_54:%.*]], [[VAL_55:%.*]] = gpu.shuffle [[VAL_0]], [[VAL_6]], [[VAL_5]] xor : f32
    // CHECK:   [[VAL_56:%.*]] = addf [[VAL_0]], [[VAL_54]] : f32
    // CHECK:   [[VAL_57:%.*]], [[VAL_58:%.*]] = gpu.shuffle [[VAL_56]], [[VAL_7]], [[VAL_5]] xor : f32
    // CHECK:   [[VAL_59:%.*]] = addf [[VAL_56]], [[VAL_57]] : f32
    // CHECK:   [[VAL_60:%.*]], [[VAL_61:%.*]] = gpu.shuffle [[VAL_59]], [[VAL_8]], [[VAL_5]] xor : f32
    // CHECK:   [[VAL_62:%.*]] = addf [[VAL_59]], [[VAL_60]] : f32
    // CHECK:   [[VAL_63:%.*]], [[VAL_64:%.*]] = gpu.shuffle [[VAL_62]], [[VAL_9]], [[VAL_5]] xor : f32
    // CHECK:   [[VAL_65:%.*]] = addf [[VAL_62]], [[VAL_63]] : f32
    // CHECK:   [[VAL_66:%.*]], [[VAL_67:%.*]] = gpu.shuffle [[VAL_65]], [[VAL_10]], [[VAL_5]] xor : f32
    // CHECK:   [[VAL_68:%.*]] = addf [[VAL_65]], [[VAL_66]] : f32
    // CHECK:   br ^bb18([[VAL_68]] : f32)
    // CHECK: ^bb18([[VAL_69:%.*]]: f32):
    // CHECK:   cond_br [[VAL_30]], ^bb19, ^bb20
    // CHECK: ^bb19:
    // CHECK:   [[VAL_70:%.*]] = divi_signed [[VAL_27]], [[VAL_5]] : i32
    // CHECK:   [[VAL_71:%.*]] = index_cast [[VAL_70]] : i32 to index
    // CHECK:   store [[VAL_69]], [[VAL_1]]{{\[}}[[VAL_71]]] : memref<32xf32, 3>
    // CHECK:   br ^bb21
    // CHECK: ^bb20:
    // CHECK:   br ^bb21
    // CHECK: ^bb21:
    // CHECK:   gpu.barrier
    // CHECK:   [[VAL_72:%.*]] = addi [[VAL_28]], [[VAL_2]] : i32
    // CHECK:   [[VAL_73:%.*]] = divi_signed [[VAL_72]], [[VAL_5]] : i32
    // CHECK:   [[VAL_74:%.*]] = cmpi "slt", [[VAL_27]], [[VAL_73]] : i32
    // CHECK:   cond_br [[VAL_74]], ^bb22, ^bb41
    // CHECK: ^bb22:
    // CHECK:   [[VAL_75:%.*]] = index_cast [[VAL_27]] : i32 to index
    // CHECK:   [[VAL_76:%.*]] = load [[VAL_1]]{{\[}}[[VAL_75]]] : memref<32xf32, 3>
    // CHECK:   [[VAL_77:%.*]] = cmpi "slt", [[VAL_73]], [[VAL_5]] : i32
    // CHECK:   cond_br [[VAL_77]], ^bb23, ^bb39
    // CHECK: ^bb23:
    // CHECK:   [[VAL_78:%.*]], [[VAL_79:%.*]] = gpu.shuffle [[VAL_76]], [[VAL_6]], [[VAL_73]] xor : f32
    // CHECK:   cond_br [[VAL_79]], ^bb24, ^bb25
    // CHECK: ^bb24:
    // CHECK:   [[VAL_80:%.*]] = addf [[VAL_76]], [[VAL_78]] : f32
    // CHECK:   br ^bb26([[VAL_80]] : f32)
    // CHECK: ^bb25:
    // CHECK:   br ^bb26([[VAL_76]] : f32)
    // CHECK: ^bb26([[VAL_81:%.*]]: f32):
    // CHECK:   [[VAL_82:%.*]], [[VAL_83:%.*]] = gpu.shuffle [[VAL_81]], [[VAL_7]], [[VAL_73]] xor : f32
    // CHECK:   cond_br [[VAL_83]], ^bb27, ^bb28
    // CHECK: ^bb27:
    // CHECK:   [[VAL_84:%.*]] = addf [[VAL_81]], [[VAL_82]] : f32
    // CHECK:   br ^bb29([[VAL_84]] : f32)
    // CHECK: ^bb28:
    // CHECK:   br ^bb29([[VAL_81]] : f32)
    // CHECK: ^bb29([[VAL_85:%.*]]: f32):
    // CHECK:   [[VAL_86:%.*]], [[VAL_87:%.*]] = gpu.shuffle [[VAL_85]], [[VAL_8]], [[VAL_73]] xor : f32
    // CHECK:   cond_br [[VAL_87]], ^bb30, ^bb31
    // CHECK: ^bb30:
    // CHECK:   [[VAL_88:%.*]] = addf [[VAL_85]], [[VAL_86]] : f32
    // CHECK:   br ^bb32([[VAL_88]] : f32)
    // CHECK: ^bb31:
    // CHECK:   br ^bb32([[VAL_85]] : f32)
    // CHECK: ^bb32([[VAL_89:%.*]]: f32):
    // CHECK:   [[VAL_90:%.*]], [[VAL_91:%.*]] = gpu.shuffle [[VAL_89]], [[VAL_9]], [[VAL_73]] xor : f32
    // CHECK:   cond_br [[VAL_91]], ^bb33, ^bb34
    // CHECK: ^bb33:
    // CHECK:   [[VAL_92:%.*]] = addf [[VAL_89]], [[VAL_90]] : f32
    // CHECK:   br ^bb35([[VAL_92]] : f32)
    // CHECK: ^bb34:
    // CHECK:   br ^bb35([[VAL_89]] : f32)
    // CHECK: ^bb35([[VAL_93:%.*]]: f32):
    // CHECK:   [[VAL_94:%.*]], [[VAL_95:%.*]] = gpu.shuffle [[VAL_93]], [[VAL_10]], [[VAL_73]] xor : f32
    // CHECK:   cond_br [[VAL_95]], ^bb36, ^bb37
    // CHECK: ^bb36:
    // CHECK:   [[VAL_96:%.*]] = addf [[VAL_93]], [[VAL_94]] : f32
    // CHECK:   br ^bb38([[VAL_96]] : f32)
    // CHECK: ^bb37:
    // CHECK:   br ^bb38([[VAL_93]] : f32)
    // CHECK: ^bb38([[VAL_97:%.*]]: f32):
    // CHECK:   br ^bb40([[VAL_97]] : f32)
    // CHECK: ^bb39:
    // CHECK:   [[VAL_98:%.*]], [[VAL_99:%.*]] = gpu.shuffle [[VAL_76]], [[VAL_6]], [[VAL_5]] xor : f32
    // CHECK:   [[VAL_100:%.*]] = addf [[VAL_76]], [[VAL_98]] : f32
    // CHECK:   [[VAL_101:%.*]], [[VAL_102:%.*]] = gpu.shuffle [[VAL_100]], [[VAL_7]], [[VAL_5]] xor : f32
    // CHECK:   [[VAL_103:%.*]] = addf [[VAL_100]], [[VAL_101]] : f32
    // CHECK:   [[VAL_104:%.*]], [[VAL_105:%.*]] = gpu.shuffle [[VAL_103]], [[VAL_8]], [[VAL_5]] xor : f32
    // CHECK:   [[VAL_106:%.*]] = addf [[VAL_103]], [[VAL_104]] : f32
    // CHECK:   [[VAL_107:%.*]], [[VAL_108:%.*]] = gpu.shuffle [[VAL_106]], [[VAL_9]], [[VAL_5]] xor : f32
    // CHECK:   [[VAL_109:%.*]] = addf [[VAL_106]], [[VAL_107]] : f32
    // CHECK:   [[VAL_110:%.*]], [[VAL_111:%.*]] = gpu.shuffle [[VAL_109]], [[VAL_10]], [[VAL_5]] xor : f32
    // CHECK:   [[VAL_112:%.*]] = addf [[VAL_109]], [[VAL_110]] : f32
    // CHECK:   br ^bb40([[VAL_112]] : f32)
    // CHECK: ^bb40([[VAL_113:%.*]]: f32):
    // CHECK:   store [[VAL_113]], [[VAL_1]]{{\[}}[[VAL_4]]] : memref<32xf32, 3>
    // CHECK:   br ^bb42
    // CHECK: ^bb41:
    // CHECK:   br ^bb42
    // CHECK: ^bb42:
    // CHECK:   gpu.barrier
    // CHECK:   [[VAL_114:%.*]] = load [[VAL_1]]{{\[}}[[VAL_4]]] : memref<32xf32, 3>
    %sum = "gpu.all_reduce"(%arg0) ({}) {op = "add"} : (f32) -> (f32)
    gpu.return
  }

}
