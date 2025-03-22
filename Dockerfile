# This is a docker image to compile code for Kalray MPPA
FROM ubuntu:22.04
ENV DEBIAN_FRONTEND=noninteractive

# Install dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    apt-utils \
    cmake \
    ninja-build \
    python3 \
    python3-pip \
    python3-setuptools \
    python3-venv \
    git \
    wget \
    curl \
    zlib1g-dev \
    libxml2-dev \
    libedit-dev \
    libncurses5-dev \
    libtool \
    libffi-dev \
    libssl-dev \
    pkg-config \
    unzip \
    lld \
    clang \
    libelf-dev \
    libudev-dev \
    xz-utils \
    rsync \
    ccache \
    llvm \
    && apt-get clean && apt-get -y autoremove && rm -rf /var/lib/apt/lists/*

# Install ACE packages and clean-up installation
RUN apt-get update && apt-get install -y /installer/install/Ubuntu_${UBUNTU_VERSION}/*.deb \
    && rm -rf /installer/

##### LLVM-COMPILATION #####
ENV LLVM_REPO="${GIT_REPO}/${GIT_USER}/llvm-project.git"
ENV LLVM_BRANCH="openmp_taskgraph"

# Clone the repository
RUN git clone --branch $LLVM_BRANCH --single-branch --depth 1 https://$LLVM_REPO /llvm-project

WORKDIR /llvm-project

RUN mkdir build && cd build && \
  cmake \
    -DLLVM_ENABLE_PROJECTS="clang;openmp" \
    -DLLVM_BUILD_EXAMPLES=OFF \
    -DCMAKE_CXX_COMPILER=clang++ \
    -DCMAKE_C_COMPILER=clang \
    -DLLVM_CCACHE_BUILD=ON \
    -DCMAKE_BUILD_TYPE=Release \
    -DLLVM_ENABLE_ASSERTIONS=ON \
    -DLLVM_USE_LINKER=lld-18 \
    -DCMAKE_EXPORT_COMPILE_COMMANDS=OFF \
    -DLLVM_TARGETS_TO_BUILD="Native" \
    -DCMAKE_INSTALL_PREFIX=/usr/clang-x86 \
    -DLIBOMP_OMPX_TASKGRAPH=TRUE \
    -G Ninja ../llvm && \
  ninja install

#### Build benchmarks ####
# Set up repository details
ENV BENCH_REPO="${GIT_REPO}/${GIT_USER}/omp-taskgraph-benchs.git"
ENV BENCH_BRANCH="develop"

# Clone the repository
RUN git clone --branch $BENCH_BRANCH --single-branch --depth 1 https://$BENCH_REPO /llvm-project

WORKDIR /omp-taskgrraph-bencys

RUN MKL_PATH=~/intel/oneapi/mkl/2024.1 && \
  OPENCV_PATH=/usr/local/ && \
  OMP_PATH=/usr/clang-x86 && \
  make

# Default command to execute when a container starts
CMD ["/bin/bash", "-c"]

