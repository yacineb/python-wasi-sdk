FROM ubuntu:22.04
ARG SDKROOT=/build/wasm-sdk

RUN apt-get update --fix-missing && \
    apt-get install -y python3.9 bash patchelf wget lz4 build-essential -y

WORKDIR ${SDKROOT}

ENV BUILDS=3.13 \
    SDKROOT=${SDKROOT} \
    Py_GIL_DISABLED=false \
    wasisdk=true \
    gosdk=false \
    rustsdk=false \
    nimsdk=false


COPY . .
RUN ls

RUN chmod +x ./python-*-sdk.sh && bash -c "./python-wasi-sdk.sh"