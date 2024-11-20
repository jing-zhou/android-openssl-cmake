#!/bin/bash
set -u
set -e

export BUILD_ARCHS=${BUILD_ARCHS:-arm_32 arm_64}
export OPENSSL_BRANCH=openssl-3.4.0
export OPENSSL_ANDROID_API=28

export ANDROID_NDK_HOME=${ANDROID_NDK_ROOT}

export BASE=$(realpath ${BASE:-$(pwd)})

export PREFIX=$BASE/prefix

if [ -d $PREFIX ]; then
    echo "Target folder exists. Remove $PREFIX to rebuild"
    exit 1
fi

mkdir -p $PREFIX

cd $BASE
if [ ! -d openssl ]; then
    git clone --depth 1 --branch $OPENSSL_BRANCH git@github.com:jing-zhou/openssl.git 
fi
cd openssl
echo "Building OpenSSL in $(realpath $PWD), deploying to $PREFIX"

export PATH=$ANDROID_NDK_HOME/toolchains/llvm/prebuilt/linux-x86_64/bin:$PATH

if [[ "$BUILD_ARCHS" = *"arm_32"* ]]; then
    ./Configure shared android-arm -D__ANDROID_API__=$OPENSSL_ANDROID_API --prefix=$PREFIX/armeabi-v7a
    make clean
    make depend
    make -j$(nproc) build_libs
    make -j$(nproc) install_sw
fi

if [[ "$BUILD_ARCHS" = *"arm_64"* ]]; then
    ./Configure shared android-arm64 -D__ANDROID_API__=$OPENSSL_ANDROID_API --prefix=$PREFIX/arm64-v8a
    make clean
    make depend
    make -j$(nproc) build_libs
    make -j$(nproc) install_sw
fi

if [[ "$BUILD_ARCHS" = *"x86_32"* ]]; then
    ./Configure shared android-x86 -D__ANDROID_API__=$OPENSSL_ANDROID_API --prefix=$PREFIX/x86
    make clean
    make depend
    make -j$(nproc) build_libs
    make -j$(nproc) install_sw
fi

if [[ "$BUILD_ARCHS" = *"x86_64"* ]]; then
    ./Configure shared android-x86_64 -D__ANDROID_API__=$OPENSSL_ANDROID_API --prefix=$PREFIX/x86_64
    make clean
    make depend
    make -j$(nproc) build_libs
    make -j$(nproc) install_sw
fi
 
