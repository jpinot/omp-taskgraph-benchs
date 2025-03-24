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

##### OneApi install ######
# COPY third-party-programs.txt /
RUN apt-get update && apt-get upgrade -y && \
  DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
    curl ca-certificates gpg-agent software-properties-common && \
  rm -rf /var/lib/apt/lists/*
# repository to install Intel(R) oneAPI Libraries
RUN curl -fsSL https://apt.repos.intel.com/intel-gpg-keys/GPG-PUB-KEY-INTEL-SW-PRODUCTS-2023.PUB | gpg --dearmor | tee /usr/share/keyrings/intel-oneapi-archive-keyring.gpg
RUN echo "deb [signed-by=/usr/share/keyrings/intel-oneapi-archive-keyring.gpg] https://apt.repos.intel.com/oneapi all main " > /etc/apt/sources.list.d/oneAPI.list

RUN apt-get update && apt-get upgrade -y && \
  DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
    curl ca-certificates gpg-agent software-properties-common && \
  rm -rf /var/lib/apt/lists/*
# repository to install Intel(R) GPU drivers
RUN curl -fsSL https://repositories.intel.com/gpu/intel-graphics.key | gpg --dearmor | tee /usr/share/keyrings/intel-graphics-archive-keyring.gpg
RUN echo "deb [signed-by=/usr/share/keyrings/intel-graphics-archive-keyring.gpg arch=amd64] https://repositories.intel.com/gpu/ubuntu jammy unified" > /etc/apt/sources.list.d/intel-graphics.list

RUN apt-get update && apt-get upgrade -y && \
  DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
    ca-certificates build-essential pkg-config gnupg libarchive13 openssh-server openssh-client wget net-tools git cmake intel-oneapi-runtime-ccl intel-oneapi-runtime-compilers intel-oneapi-runtime-dal intel-oneapi-runtime-dnnl intel-oneapi-runtime-dpcpp-cpp intel-oneapi-runtime-dpcpp-library intel-oneapi-runtime-fortran intel-oneapi-runtime-ipp intel-oneapi-runtime-ipp-crypto intel-oneapi-runtime-libs intel-oneapi-runtime-mkl intel-oneapi-runtime-mpi intel-oneapi-runtime-opencl intel-oneapi-runtime-openmp intel-oneapi-runtime-tbb intel-oneapi-tcm-1.0 intel-opencl-icd libze-intel-gpu1 libze1 libze-dev  && \
  rm -rf /var/lib/apt/lists/*

##### OneApi install ######

##### LLVM-COMPILATION #####
# ENV SDK_INSTALLER=clang-x86
# # Copy and prepare SDK installer
# RUN mkdir -p /installer
# COPY ./$SDK_INSTALLER /installer/
# RUN mkdir -p /installer/install

# # Unpack and set up SDK
# RUN if [ -e /installer/$SDK_INSTALLER ]; then \
#       echo "ACE installer already present" && \
#       tar --strip-components=1 -xf /installer/$SDK_INSTALLER -C /installer/install; \
#     else \
#       echo "Downloading Kalray ACE failed, file not found!" && \
#       exit 1; \
#     fi

# # Install ACE packages and clean-up installation
# # RUN apt-get update && apt-get install -y /installer/install/Ubuntu_${UBUNTU_VERSION}/*.deb \
# #     && rm -rf /installer/
# # TODO: remove installer
# RUN mv /installer/install /usr/


# ENV LLVM_REPO="${GIT_REPO}/${GIT_USER}/llvm-project.git"
# ENV LLVM_BRANCH="openmp_taskgraph"

# # Clone the repository
# RUN git clone --branch $LLVM_BRANCH --single-branch --depth 1 https://$LLVM_REPO /llvm-project

# WORKDIR /llvm-project

# RUN mkdir build && cd build && \
#   cmake \
#     -DLLVM_ENABLE_PROJECTS="clang;openmp" \
#     -DLLVM_BUILD_EXAMPLES=OFF \
#     -DCMAKE_CXX_COMPILER=clang++ \
#     -DCMAKE_C_COMPILER=clang \
#     -DLLVM_CCACHE_BUILD=ON \
#     -DCMAKE_BUILD_TYPE=Release \
#     -DLLVM_ENABLE_ASSERTIONS=ON \
#     -DLLVM_USE_LINKER=lld \
#     -DLLVM_USE_SPLIT_DWARF=ON \
#     -DCMAKE_EXPORT_COMPILE_COMMANDS=OFF \
#     -DLLVM_TARGETS_TO_BUILD="Native" \
#     -DCMAKE_INSTALL_PREFIX=/usr/clang-x86 \
#     -DLIBOMP_OMPX_TASKGRAPH=TRUE \
#     -G Ninja ../llvm && \
#   ninja install

# #### Build benchmarks ####
# # Set up repository details
# ENV BENCH_REPO="${GIT_REPO}/${GIT_USER}/omp-taskgraph-benchs.git"
# ENV BENCH_BRANCH="develop"

# # Clone the repository
# RUN git clone --branch $BENCH_BRANCH --single-branch --depth 1 https://$BENCH_REPO /llvm-project

# WORKDIR /omp-taskgraph-benchs

# RUN MKL_PATH=~/intel/oneapi/mkl/2024.1 && \
#   OPENCV_PATH=/usr/local/ && \
#   OMP_PATH=/usr/clang-x86 && \
#   make

# Default command to execute when a container starts
CMD ["/bin/bash", "-c"]

