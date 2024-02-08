#!/bin/bash

SDKROOT=${SDKROOT:-/opt/python-wasm-sdk}

if [[ -z ${WASISDK+z} ]]
then

    . ${CONFIG:-${SDKROOT}/config}

    export WASISDK="${SDKROOT}/wasisdk"
    export WASI_SDK_PREFIX="${WASISDK}/upstream"
    export WASI_SYSROOT="${WASI_SDK_PREFIX}/share/wasi-sysroot"

    export CMAKE_TOOLCHAIN_FILE=${SDKROOT}/wasisdk/share/cmake/Modules/Platform/WASI.cmake
    export CMAKE_INSTALL_PREFIX="${SDKROOT}/devices/wasisdk/usr"

    if [ -d ${WASI_SDK_PREFIX}/bin ]
    then
        echo "
        * using wasisdk from $(realpath ${SDKROOT}/wasisdk/upstream)
            with sys python $SYS_PYTHON and host python $HPY
        and toolchain file CMAKE_TOOLCHAIN_FILE=$CMAKE_TOOLCHAIN_FILE

" 1>&2
    else
        chmod +x ${SDKROOT}/scripts/*.sh
        . ${SDKROOT}/scripts/wasisdk-fetch.sh
    fi

    export PATH="${WASISDK}/bin:${WASI_SDK_PREFIX}/bin:$PATH"

    export PREFIX=$CMAKE_INSTALL_PREFIX

    # instruct pkg-config to use wasi target root
    export PKG_CONFIG_PATH="${PREFIX}/lib/pkgconfig:${WASI_SYSROOT}/lib/wasm32-wasi/pkgconfig"

    # for thirparty prebuilts .pc in sdk
    export PKG_CONFIG_LIBDIR="${WASI_SYSROOT}/lib/wasm32-wasi/pkgconfig"
    #:${WASI_SYSROOT}/share/pkgconfig"
    export PKG_CONFIG_SYSROOT_DIR="${WASI_SYSROOT}"


    export PS1="[PyDK:wasi] \w $ "

    export LDSHARED="${WASI_SDK_PREFIX}/bin/wasm-ld"
    export AR="${WASI_SDK_PREFIX}/bin/llvm-ar"
    export RANLIB="${WASI_SDK_PREFIX}/bin/ranlib"

    export CC="${WASISDK}/bin/wasi-c"
    export CPP="${WASISDK}/bin/wasi-cpp"
    export CXX="${WASISDK}/bin/wasi-c++"

else
    echo "wasidk: config already set !" 1>&2
fi
