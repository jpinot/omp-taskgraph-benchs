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
    ca-certificates build-essential pkg-config gnupg libarchive13 openssh-server openssh-client wget net-tools git cmake intel-cpp-essentials intel-opencl-icd libze-intel-gpu1 libze1 libze-dev  && \
  rm -rf /var/lib/apt/lists/*

ENV LANG=C.UTF-8
ENV CMAKE_PREFIX_PATH='/opt/intel/oneapi/tbb/2022.0/env/..:/opt/intel/oneapi/mkl/2025.0/lib/cmake:/opt/intel/oneapi/dpl/2022.7/lib/cmake/oneDPL:/opt/intel/oneapi/compiler/2025.0'
ENV CMPLR_ROOT='/opt/intel/oneapi/compiler/2025.0'
ENV CPATH='/opt/intel/oneapi/umf/0.9/include:/opt/intel/oneapi/tbb/2022.0/env/../include:/opt/intel/oneapi/mkl/2025.0/include:/opt/intel/oneapi/dpl/2022.7/include:/opt/intel/oneapi/dpcpp-ct/2025.0/include:/opt/intel/oneapi/dev-utilities/2025.0/include'
ENV DIAGUTIL_PATH='/opt/intel/oneapi/dpcpp-ct/2025.0/etc/dpct/sys_check/sys_check.sh:/opt/intel/oneapi/compiler/2025.0/etc/compiler/sys_check/sys_check.sh'
ENV DPL_ROOT='/opt/intel/oneapi/dpl/2022.7'
ENV GDB_INFO='/opt/intel/oneapi/debugger/2025.0/share/info/'
ENV INFOPATH='/opt/intel/oneapi/debugger/2025.0/share/info'
ENV INTEL_PYTHONHOME='/opt/intel/oneapi/debugger/2025.0/opt/debugger'
ENV LD_LIBRARY_PATH='/opt/intel/oneapi/tcm/1.2/lib:/opt/intel/oneapi/umf/0.9/lib:/opt/intel/oneapi/tbb/2022.0/env/../lib/intel64/gcc4.8:/opt/intel/oneapi/mkl/2025.0/lib:/opt/intel/oneapi/debugger/2025.0/opt/debugger/lib:/opt/intel/oneapi/compiler/2025.0/opt/compiler/lib:/opt/intel/oneapi/compiler/2025.0/lib'
ENV LIBRARY_PATH='/opt/intel/oneapi/tcm/1.2/lib:/opt/intel/oneapi/umf/0.9/lib:/opt/intel/oneapi/tbb/2022.0/env/../lib/intel64/gcc4.8:/opt/intel/oneapi/mkl/2025.0/lib:/opt/intel/oneapi/compiler/2025.0/lib'
ENV MANPATH='/opt/intel/oneapi/debugger/2025.0/share/man:/opt/intel/oneapi/compiler/2025.0/share/man:'
ENV MKLROOT='/opt/intel/oneapi/mkl/2025.0'
ENV NLSPATH='/opt/intel/oneapi/compiler/2025.0/lib/compiler/locale/%l_%t/%N'
ENV OCL_ICD_FILENAMES='/opt/intel/oneapi/compiler/2025.0/lib/libintelocl.so'
ENV ONEAPI_ROOT='/opt/intel/oneapi'
ENV PATH='/opt/intel/oneapi/mkl/2025.0/bin:/opt/intel/oneapi/dpcpp-ct/2025.0/bin:/opt/intel/oneapi/dev-utilities/2025.0/bin:/opt/intel/oneapi/debugger/2025.0/opt/debugger/bin:/opt/intel/oneapi/compiler/2025.0/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin'
ENV PKG_CONFIG_PATH='/opt/intel/oneapi/tbb/2022.0/env/../lib/pkgconfig:/opt/intel/oneapi/mkl/2025.0/lib/pkgconfig:/opt/intel/oneapi/dpl/2022.7/lib/pkgconfig:/opt/intel/oneapi/compiler/2025.0/lib/pkgconfig'
ENV SETVARS_COMPLETED='1'
ENV TBBROOT='/opt/intel/oneapi/tbb/2022.0/env/..'
ENV TCM_ROOT='/opt/intel/oneapi/tcm/1.2'
ENV UMF_ROOT='/opt/intel/oneapi/umf/0.9'

##### OpenCV install ######
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
