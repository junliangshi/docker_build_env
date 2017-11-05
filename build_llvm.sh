#!/bin/bash
set -exv
## modify the following as needed for your environment
# location where clang should be installed
LLVM_RELEASE=5.0.0
INSTALL_PREFIX=/home/jshi/bin64/llvm-${LLVM_RELEASE}
# location of gcc used to build clang
#HOST_GCC=/home/jshi/bin64/gcc4.9.1
HOST_GCC=
# number of cores
CPUS=2
# uncomment following to get verbose output from make
#VERBOSE=VERBOSE=1
# uncomment following if you need to sudo in order to do the install
#SUDO=sudo


mkdir -p llvm-${LLVM_RELEASE}
cd llvm-${LLVM_RELEASE}
curl -O "https://llvm.org/releases/${LLVM_RELEASE}/llvm-${LLVM_RELEASE}.src.tar.xz"
curl -O "https://llvm.org/releases/${LLVM_RELEASE}/cfe-${LLVM_RELEASE}.src.tar.xz"
curl -O "https://llvm.org/releases/${LLVM_RELEASE}/compiler-rt-${LLVM_RELEASE}.src.tar.xz"
curl -O "https://llvm.org/releases/${LLVM_RELEASE}/libcxx-${LLVM_RELEASE}.src.tar.xz"
curl -O "https://llvm.org/releases/${LLVM_RELEASE}/libcxxabi-${LLVM_RELEASE}.src.tar.xz"
curl -O "https://llvm.org/releases/${LLVM_RELEASE}/libunwind-${LLVM_RELEASE}.src.tar.xz"
curl -O "https://llvm.org/releases/${LLVM_RELEASE}/lld-${LLVM_RELEASE}.src.tar.xz"
if [[ ${ENABLE_LLDB} == true ]]; then
    curl -O "http://llvm.org/releases/${LLVM_RELEASE}/lldb-${LLVM_RELEASE}.src.tar.xz"
fi
curl -O "http://llvm.org/releases/${LLVM_RELEASE}/openmp-${LLVM_RELEASE}.src.tar.xz"
curl -O "http://llvm.org/releases/${LLVM_RELEASE}/clang-tools-extra-${LLVM_RELEASE}.src.tar.xz"

for i in $(ls *.xz); do tar xf $i;done

mv cfe-${LLVM_RELEASE}.src llvm-${LLVM_RELEASE}.src/tools/clang
mv compiler-rt-${LLVM_RELEASE}.src llvm-${LLVM_RELEASE}.src/projects/compiler-rt
mv libcxx-${LLVM_RELEASE}.src llvm-${LLVM_RELEASE}.src/projects/libcxx
mv libcxxabi-${LLVM_RELEASE}.src llvm-${LLVM_RELEASE}.src/projects/libcxxabi
mv libunwind-${LLVM_RELEASE}.src llvm-${LLVM_RELEASE}.src/projects/libunwind
mv lld-${LLVM_RELEASE}.src llvm-${LLVM_RELEASE}.src/tools/lld
if [[ ${ENABLE_LLDB} == true ]]; then
    mv lldb-${LLVM_RELEASE}.src llvm-${LLVM_RELEASE}.src/tools/lldb
fi
mv openmp-${LLVM_RELEASE}.src llvm-${LLVM_RELEASE}.src/projects/openmp
mv clang-tools-extra-${LLVM_RELEASE}.src llvm-${LLVM_RELEASE}.src/tools/clang/tools/extra

(cd llvm-${LLVM_RELEASE}.src/tools/clang/tools; git clone https://github.com/include-what-you-use/include-what-you-use.git)

## build clang w/gcc installed in non-standard location
rm -rf build
mkdir -p build
cd build
export LD_LIBRARY_PATH=/lib64:$LD_LIBRARY_PATH
cmake -D_GLIBCXX_USE_CXX11_ABI=0 \
        -DCMAKE_C_COMPILER=${HOST_GCC}/bin/gcc \
        -DCMAKE_CXX_COMPILER=${HOST_GCC}/bin/g++ \
        -DGCC_INSTALL_PREFIX=${HOST_GCC} \
        -DCMAKE_CXX_LINK_FLAGS="-L${HOST_GCC}/lib64 -Wl,-rpath,${HOST_GCC}/lib64 -Wl,--enable-new-dtags" \
        -DCMAKE_INSTALL_PREFIX=${INSTALL_PREFIX} \
        -DLLVM_ENABLE_ASSERTIONS=OFF \
        -DLLVM_INCLUDE_EXAMPLES=OFF \
        -DLLVM_BUILD_TESTS=OFF \
        -DLLVM_INCLUDE_TESTS=OFF \
        -DLLVM_ENABLE_EH=ON \
        -DLLVM_ENABLE_RTTI=ON \
        -DBUILD_SHARED_LIBS=ON \
        -DCMAKE_BUILD_TYPE="Release" \
        -DLLVM_TARGETS_TO_BUILD="X86" \
        -DLLVM_BUILD_EXTERNAL_COMPILER_RT=ON \
        -DLLVM_ENABLE_LIBCXX=ON ../llvm

make -j ${CPUS} ${VERBOSE}

# install it
${SUDO} rm -rf ${INSTALL_PREFIX}
${SUDO} make install
cp bin/include-what-you-use ${PREFIX}/bin

# we need some addl bits that are not normally installed
#    ${SUDO} cp -p ../llvm/tools/clang/tools/scan-build/scan-build  ${INSTALL_PREFIX}/bin
#    ${SUDO} cp -p ../llvm/tools/clang/tools/scan-build/ccc-analyzer  ${INSTALL_PREFIX}/bin
#    ${SUDO} cp -p ../llvm/tools/clang/tools/scan-build/c++-analyzer  ${INSTALL_PREFIX}/bin
#    ${SUDO} cp -p ../llvm/tools/clang/tools/scan-build/sorttable.js  ${INSTALL_PREFIX}/bin
#    ${SUDO} cp -p ../llvm/tools/clang/tools/scan-build/scanview.css ${INSTALL_PREFIX}/bin
#    ${SUDO} cp -rp ../llvm/tools/clang/tools/scan-view/*  ${INSTALL_PREFIX}
