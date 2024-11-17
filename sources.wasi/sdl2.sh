#!/bin/bash

. ${CONFIG:-config}


cd ${ROOT}/src

PKG=SDL2


if [ -f ${PKG}.patched ]
then
    echo "
        ${PKG} already prepared
    "
else
    git clone --no-tags --depth 1 --single-branch --branch SDL2 https://github.com/libsdl-org/SDL SDL2
    pushd ${PKG}
        patch p1 < ${ROOT}/sources.wasi/sdl2.diff
    popd
    touch ${PKG}.patched
fi


if [ -f $PREFIX/lib/lib${PKG}.a ]
then
    echo "
        already built in $PREFIX/lib/lib${PKG}.a
    "
else

    . ${WASISDK}/wasisdk_env.sh

    mkdir -p ${ROOT}/build/${PKG}
    pushd ${ROOT}/build/${PKG}
    if wasi-cmake cmake \
     -DSDL_PTHREADS=OFF -DSDL_THREADS=OFF -DSDL_ASSEMBLY=OFF \
     -DSDL_ALSA=OFF \
     ${ROOT}/src/${PKG}
    then
        make install
    else
        echo "SDL2 build failed"
        popd
        exit 47
    fi
    popd
fi

