FROM ubuntu:22.04

# Set non-interactive mode for apt
ENV DEBIAN_FRONTEND=noninteractive

# Update package list and install basic dependencies
RUN apt-get update && apt-get install -y \
    git \
    vim \
    net-tools\
    netcat\
    && rm -rf /var/lib/apt/lists/*

#RISC-V GNU toolchain build deps
RUN apt-get update && apt-get install -y \
    autoconf \
    automake \
    autotools-dev \
    curl \
    python3 \
    python3-pip \
    python3-tomli \
    libmpc-dev \
    libmpfr-dev \
    libgmp-dev \
    gawk \
    build-essential \
    bison \
    flex \
    texinfo \
    gperf \
    libtool \
    patchutils \
    bc \
    zlib1g-dev \
    libexpat-dev \
    ninja-build \
    git \
    cmake \
    libglib2.0-dev \
    libslirp-dev \
    && rm -rf /var/lib/apt/lists/*


# Set up RISC-V toolchain directory and env-var
ENV RISCV="/opt/riscv"
ENV PATH="$RISCV/bin:$PATH"

# Download RISC-V GNU toolchain with newlib
WORKDIR /tmp 
RUN git clone https://github.com/riscv/riscv-gnu-toolchain.git
WORKDIR /tmp/riscv-gnu-toolchain

# Configure and build the toolchain with newlib
RUN ./configure --prefix=$RISCV 
RUN make -j32 #remove32

# Create a simple hello world program to test riscv toolchain
WORKDIR /app_test_riscv_toolchain
RUN cat > hello.c << 'EOF'
#include <stdio.h>

int main() {
    printf("Hello, RISC-V World!\n");
    return 0;
}
EOF

# Compile the hello world program
RUN riscv64-unknown-elf-gcc -o hello hello.c

#Do not consider depenedencies up to this point, RISCV toolchain is probably already present in cnodes.

#OpenOCD is required to debug spike runnable elf with gdb 
ENV OPENOCD="/opt/openocd"
ENV OPENOCD_REVISION="9ea7f3d647c8ecf6b0f1424002dfc3f4504a162c"
# openocd dependencies
RUN apt-get update && apt-get install --no-install-recommends -y \
  openocd\ 
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*


 



#SPIKE toolchain build deps (todo: versioning of third party)
RUN apt-get update && apt-get install -y \
    python3-venv \
    python3-pip \
    device-tree-compiler\
    libssl-dev\
    gdb\
    && rm -rf /var/lib/apt/lists/*
 

#Clone axelera spike SW team instance 
#Require docker build option --secret id=ssh_key,src="$your_key_path" -t $your_image_name .
#(todo: versioning of third git@github.com:axelera-ai/tools.riscv-isa-sim.git)
WORKDIR /spike 
RUN mkdir -p ~/.ssh && \
    ssh-keyscan github.com >> ~/.ssh/known_hosts


RUN --mount=type=secret,id=ssh_key,dst=/root/.ssh/id_rsa \
    eval "$(ssh-agent -s)" &&\
    ssh-add /root/.ssh/id_rsa &&\
    ls -la ~/.ssh/ && \
    ssh-add -l  &&\
    git clone   git@github.com:axelera-ai/tools.riscv-isa-sim.git  /spike/tools.riscv.isa-sim


WORKDIR /spike/tools.riscv.isa-sim
RUN ls -la

#Install dependencies
RUN ./docker-images/ubuntu/Docker/common-scripts/install-pipx-and-python-utilities.sh 
RUN ./docker-images/ubuntu/Docker/common-scripts/install-ninja.sh
RUN ./docker-images/ubuntu/Docker/common-scripts/install-ccache.sh
RUN ./docker-images/ubuntu/Docker/common-scripts/install-cmake.sh

#Build with debugging symbols and no build optimization
RUN make CFLAGS="-g -O0" CXXFLAGS="-g -O0" build-Release  
RUN make install-Release

#Test run
RUN ./install-Release/bin/ax-accel-sim run-elf  --generation EUROPA  axelera/tests/apps/test_conv_identity_pt_struct_ai0

#(TODO: Verify what is required to install in a different directory e.g /usr/bin)



# Default command
CMD ["bash"]