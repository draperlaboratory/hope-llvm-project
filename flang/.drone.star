def clang(arch):
    return {
        "kind": "pipeline",
        "name": "%s-clang" % arch,
        "steps": [
            {
                "name": "test",
                "image": "ubuntu",
                "commands": [
                    "apt-get update && apt-get install -y clang-8 cmake ninja-build lld-8 llvm-8-dev libc++-8-dev libc++abi-8-dev libz-dev git",
                    "git clone https://github.com/llvm/llvm-project",
                    "mkdir llvm-project/build && cd llvm-project/build",
                    'env CC=clang-8 CXX=clang++-8 CXXFLAGS="-stdlib=libc++" LDFLAGS="-fuse-ld=lld" cmake -GNinja -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=../install -DLLVM_TARGETS_TO_BUILD=host -DLLVM_ENABLE_PROJECTS="clang;mlir" ../llvm',
                    "ninja",
                    "cd ../..",
                    "mkdir build && cd build",
                    'env CC=clang-8 CXX=clang++-8 CXXFLAGS="-UNDEBUG -stdlib=libc++" LDFLAGS="-fuse-ld=lld" cmake -GNinja -DCMAKE_BUILD_TYPE=Release .. -DLLVM_DIR=/drone/src/llvm-project/build/lib/cmake/llvm',
                    "ninja -j8",
                    "ctest --output-on-failure -j24",
                    "ninja check-all",
                ],
            },
        ],

    }

def gcc(arch):
    return {
            "kind": "pipeline",
            "name": "%s-gcc" % arch,
            "steps": [
                {
                    "name": "test",
                    "image": "gcc",
                    "commands": [
			"apt-get update && apt-get install -y cmake ninja-build llvm-dev libz-dev git",
		        "git clone https://github.com/llvm/llvm-project",
		        "mkdir llvm-project/build && cd llvm-project/build",
		        'env CC=gcc CXX=g++ LDFLAGS="-fuse-ld=gold" cmake -GNinja -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=../install -DLLVM_TARGETS_TO_BUILD=host -DLLVM_ENABLE_PROJECTS="clang;mlir" ../llvm',
                        "ninja",
                        "cd ../..",
                        "mkdir build && cd build",
                        'env CC=gcc CXX=g++ CXXFLAGS="-UNDEBUG" LDFLAGS="-fuse-ld=gold" cmake -GNinja -DCMAKE_BUILD_TYPE=Release .. -DLLVM_DIR=/drone/src/llvm-project/build/lib/cmake/llvm',
                        "ninja -j8",
                        "ctest --output-on-failure -j24",
                        "ninja check-all",
                    ],
                },
            ],

        }

def main(ctx):
    return [
        clang("amd64"),
        clang("arm64"),
        gcc("amd64"),
        gcc("arm64"),
    ]

