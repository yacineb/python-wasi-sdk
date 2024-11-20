#!/bin/bash

export SDKROOT=${SDKROOT:-/tmp/sdk}

pushd ${SDKROOT}
    . ${CONFIG:-config}
    . wasm32-bi-emscripten-shell.sh
popd

curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs > getrust
bash ./getrust -y -t wasm32-unknown-unknown --default-toolchain nightly

. $SDKROOT/rust/env


rustup target add wasm32-unknown-unknown
rustup target add wasm32-unknown-emscripten
rustup target add wasm32-wasip1


