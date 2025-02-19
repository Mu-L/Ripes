FROM ubuntu

ARG DEBIAN_FRONTEND=noninteractive

RUN apt-get update -q \
    && apt-get install -qy --no-install-recommends \
    build-essential \
    cmake \
    gcc-riscv64-unknown-elf \
    git \
    libpthread-stubs0-dev \
    python3 \
    python3-pip \
    && apt-get -y autoremove \
    && apt-get -y autoclean \
    && rm -rf /var/lib/apt/lists/*

RUN python3 -m pip install aqtinstall

# from https://ddalcino.github.io/aqt-list-server/
RUN aqt install-qt linux desktop 6.5.0 gcc_64 -m qtcharts

ARG GIT_SSL_NO_VERIFY=true
ENV LC_ALL=C.UTF-8 SHELL=/bin/bash

ARG BRANCH=master
RUN git clone --recursive --branch ${BRANCH} https://github.com/mortbopet/Ripes.git /tmp/ripes \
    && cmake -S /tmp/ripes/ -B /tmp/ripes/build \
    -Wno-dev -DRIPES_BUILD_TESTS=ON -DVSRTL_BUILD_TESTS=ON -DCMAKE_BUILD_TYPE=Release \
    && cmake --build /tmp/ripes/build \
    && cd /tmp/ripes/build/test \
    && ./tst_assembler && ./tst_expreval && ./tst_riscv \
    && cd /tmp/ripes/build \
    && make install \
    && cd /tmp \
    && rm -rf /tmp/ripes

ENTRYPOINT ["Ripes"]
