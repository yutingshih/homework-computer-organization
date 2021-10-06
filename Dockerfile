FROM ubuntu:20.04
RUN apt update && DEBIAN_FRONTEND=noninteractive apt install -y \
    vim git autoconf automake autotools-dev curl python3 libmpc-dev \
    libmpfr-dev libgmp-dev gawk build-essential bison flex texinfo \
    gperf libtool patchutils bc zlib1g-dev libexpat-dev

LABEL version="0.1"
LABEL maintainer="Yu-Ting Shih<c24066096@gs.ncku.edu.tw>"
LABEL description="docker environment for RISC-V GNU Compiler Toolchain"

WORKDIR /root
RUN mkdir -p ${HOME}/riscv && \
    echo 'export PATH="${PATH}:${HOME}/riscv/bin"' >> ${HOME}/.bashrc

RUN [ -d ${HOME}/riscv-gnu-toolchain ] || \
    git clone https://github.com/riscv/riscv-gnu-toolchain

RUN cd ${HOME}/riscv-gnu-toolchain && mkdir build && cd build && \
    ../configure --prefix=${HOME}/riscv --with-arch=rv32gc --with-abi=ilp32 && \
    make

CMD ["/bin/bash"]
