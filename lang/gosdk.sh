#!/bin/bash

export SDKROOT=${SDKROOT:-/tmp/sdk}

pushd ${SDKROOT}
    . ${CONFIG:-config}

    GOARCHIVE=go1.23.2.linux-amd64.tar.gz
    wget -c https://go.dev/dl/${GOARCHIVE}
    tar xvfz ${GOARCHIVE} && rm ${GOARCHIVE}
    ./go/bin/go telemetry off
popd

