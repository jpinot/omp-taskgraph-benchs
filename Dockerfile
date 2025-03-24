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
# Download and unpack sources
RUN wget -O opencv.zip https://github.com/opencv/opencv/archive/4.x.zip && \
  unzip opencv.zip
 
# Build
RUN mkdir -p build && cd build && \
  cmake CMAKE_INSTALL_PREFIX=/usr/ -GNinja ../opencv-4.x && ninja install

##### LLVM-COMPILATION #####
# ENV SDK_INSTALLER=clang-x86*
ENV SDK_INSTALLER="clang-x86-openmp_taskgraph-6ee4ac22580f.zip"
# Copy and prepare SDK installer
RUN mkdir -p /installer
COPY ./$SDK_INSTALLER /installer/
RUN mkdir -p /installer/install

# Unpack and set up SDK
RUN if [ -e /installer/$SDK_INSTALLER ]; then \
      echo "SDK found" && \
      unzip /installer/$SDK_INSTALLER; \
    else \
      echo "Missing llvm/clang files, Need to be added in a zip file inside $SDK_INSTALLER!" && \
      exit 1; \
    fi

#### Build benchmarks ####
# Set up repository details
ENV GIT_USER="jpinot"
ENV BENCH_REPO="github.com/${GIT_USER}/omp-taskgraph-benchs.git"
ENV BENCH_BRANCH="develop"

# Clone the repository
RUN git clone --branch $BENCH_BRANCH --single-branch --depth 1 https://$BENCH_REPO /omp-taskgraph-benchs

WORKDIR /omp-taskgraph-benchs

RUN MKL_PATH=~/intel/oneapi/mkl/2024.1 \
  OPENCV_PATH=/usr/ \
  OMP_PATH=/usr/clang-x86 \
  make

# Default command to execute when a container starts
CMD ["/bin/bash", "-c"]
