#!/bin/bash

SDKROOT=${SDKROOT:-/opt/python-wasm-sdk}
CONFIG=$(realpath ${CONFIG:-config})
. $CONFIG

if [ -d ${NIMSDK} ]
then
    echo "



    will not overwrite existing working directory
        NIMSDK=${NIMSDK}



"
else
    mkdir ${NIMSDK}
fi


pushd ${NIMSDK}
    if [ -d $NIM_VERSION/bin ]
    then
        echo "

    will not overwrite existing Nim build found in
        ${NIMSDK}/$NIM_VERSION/bin


    "
    else
        if echo $NIM_URL|grep -q nim-lang\.org
        then
            echo ERROR download/install release from $NIM_URL
        else
            $GITGET devel $NIM_URL $NIM_VERSION
            pushd $NIM_VERSION
                chmod +x *sh
                CC=clang CXX=clang++ ./build_all.sh
            popd
        fi
    fi

# --usenimcache

    mkdir -p ${NIMSDK}/nim

    cat > ${NIMSDK}/nim/config.nims <<END
echo "  ==== python-nim-sdk ======"
import std/strformat

var ARCH="$(arch)"
var SDKROOT = getEnv("SDKROOT","${SDKROOT}")

--colors:on
--threads:off

echo fmt" ==== Panda3D: generic config {ARCH=} from {SDKROOT=} ===="
--cc:clang
--os:linux

--define:usemalloc
--noCppExceptions
--define:noCppExceptions
--exceptions:quirky

# gc : bohem => need libgc.so.1
--gc:orc
--define:noSignalHandler

#
--define:static

# better debug but optionnal/tweakable
--parallelBuild:1
--opt:speed
--define:debug

when defined(wasi):
    echo "  ===== Panda3D: wasi build ======"
    # overwrite
    ARCH="wasisdk"

    # needed for compiler
    --cc:clang
    --os:linux

    --define:emscripten
    --define:static

    # component model aka reactor
    --noMain

    --cpu:wasm32
    switch("clibdir", fmt"{SDKROOT}/devices/{ARCH}/usr/lib/wasm32-wasi")


    switch("passC", fmt"-m32 -Djmp_buf=int")
    switch("passC", "-Os -g3 -mllvm -inline-threshold=1")

    switch("passL","-lstdc++ ")

    # more compat but in the long term workaround Panda3D instead
    # wasi emulations
    switch("passC", "-D_GNU_SOURCE")
    switch("passC", "-D_WASI_EMULATED_MMAN -D_WASI_EMULATED_SIGNAL -D_WASI_EMULATED_PROCESS_CLOCKS -D_WASI_EMULATED_GETPID")
    switch("passL", "-lwasi-emulated-getpid -lwasi-emulated-mman -lwasi-emulated-signal -lwasi-emulated-process-clocks")


    # don't use _start/main but _initialize instead
    switch("passL", "-Wl,--export-all -mexec-model=reactor")

    # better debug but optionnal/tweakable
    --parallelBuild:1
    --opt:none

else:
    echo fmt"  ===== Panda3D: native {ARCH} build ======"
    switch("passL", "-lfreetype -lharfbuzz")
    # -lfftw3 -lassimp")

# static
switch("passL", "-lp3tinydisplay")
# common
switch("passL", "-lc -lz")

# only for script gen which does not pass cincludes
# --passC:-I/opt/python-wasm-sdk/devices/${ARCH}/usr/include/panda3d
# --passL:-L${SDKROOT}/devices/${ARCH}/usr/lib


switch("nimcache", fmt"{SDKROOT}/nimsdk/cache.{ARCH}")
switch("clibdir", fmt"{SDKROOT}/devices/{ARCH}/usr/lib")
switch("cincludes", fmt"{SDKROOT}/devices/{ARCH}/usr/include/panda3d")

switch("out", fmt"out.{ARCH}")



END

    cat > nimsdk_env.sh <<END
if [[ -z \${NIMSDK_ENV+z} ]]
then
    export NIMSDK_ENV=true
    export SDKROOT=$SDKROOT
    . $CONFIG
    . $WASISDK/wasisdk_env.sh
    export XDG_CONFIG_HOME=${NIMSDK}
    export NIMBLE_DIR=${NIMSDK}/pkg
    export PATH=${NIMSDK}/${NIM_VERSION}/bin:$PATH
    echo "

    * using nimsdk from \$(realpath \${NIMSDK}/\${NIM_VERSION}/bin)
            with sys python \$SYS_PYTHON and host python \$HPY
        toolchain file CMAKE_TOOLCHAIN_FILE=\${CMAKE_TOOLCHAIN_FILE}
        install prefix PREFIX=\${PREFIX}

        Nim from $NIMSDK/$NIM_VERSION/bin

        SDKROOT=$SDKROOT
        NIMSDK=$NIMSDK
        NIMBLE_DIR=\$NIMBLE_DIR
        PATH=$PATH

        clang=\$(which clang)
        clang++=\$(which clang++)

"

parse_git_branch() {
     git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/(\1)/'
}
    export PS1="[PyDK:nim]  \[\e[32m\]\w \[\e[91m\]\$(parse_git_branch)\[\e[00m\]\$ "

else
    echo "nimsdk: config already set !" 1>&2
fi
END

popd

