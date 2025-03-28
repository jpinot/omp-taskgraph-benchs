# tdg-benchs
Set of benchmarks used to test the performance of taskgraph. Growing

## Clang compilation

To create the SDK containing all the required LLVM, Clang, and OpenMP files for different versions, the following script was used.
Note: the flag `LIBOMP_OMPX_TASKGRAPH` can be toggled on/off for different test configurations.

```bash
#!/bin/bash

branch=$(git symbolic-ref --short HEAD)
commit=$(git rev-parse --short HEAD)
install_prefix=/home/jpinot/clang-x86-$branch-$commit

echo
echo "**** Compailing branch $branch, commit $commit"
echo

mkdir -p build && cd build && \
  cmake \
    -DLLVM_ENABLE_PROJECTS="clang;openmp" \
    -DLLVM_BUILD_EXAMPLES=OFF \
    -DCMAKE_CXX_COMPILER=/apps/clang/16.0.6/bin/clang++ \
    -DCMAKE_C_COMPILER=/apps/clang/16.0.6/bin/clang \
    -DLLVM_CCACHE_BUILD=ON \
    -DCMAKE_BUILD_TYPE=Release \
    -DLLVM_ENABLE_ASSERTIONS=ON \
    -DLLVM_USE_LINKER=lld \
    -DLLVM_USE_SPLIT_DWARF=ON \
    -DCMAKE_EXPORT_COMPILE_COMMANDS=OFF \
    -DLLVM_TARGETS_TO_BUILD="Native" \
    -DCMAKE_INSTALL_PREFIX=$install_prefix \
    -DLIBOMP_OMPX_TASKGRAPH=TRUE \
    -G Ninja ../llvm && \
  ninja install

zip -r $install_prefix.zip $install_prefix/
```

## Benchmark Compilation

The project includes a `Dockerfile` with all the necessary instructions to compile the benchmarks. It supports build customization through several arguments: `SDK_BRANCH`, `SDK_COMMIT`, `BENCHS_BRANCH`, and `BENCH_COMMIT`, which allow you to specify different build environments if needed.

After building, a `.zip` file named `clang-x86-$SDK_BRANCH-$SDK_COMMIT.zip` is generated. This file contains the install output from the Clang build.

## Execution on BSC MareNostrum 5

A build script named `run_benchs.sh` is provided to automate the execution of the benchmarks. For running on MareNostrum 5 (or any SLURM-based HPC system), the script has been extended to correctly set up the environment:

```bash
#!/bin/bash
#SBATCH --job-name=nbody-test
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=48
#SBATCH --time=02:00:00
#SBATCH --partition=debug
#SBATCH --exclusive
```

## How to Build & Run

### For benchmarks that do not belong to NAS
Firstly, set up the following environment variables (EV):
1. *OMP_PATH* : for TDG related builds, this EV needs to be set to the **TDG_INS**/lib, where **TDG_INS** is where the LLVM+Taskgraph toolchain is installed. Basically, Makefile uses this EV to correctly link the Taskgraph binaries. Otherwise, binaries using Taskgraph features will not be able to compile.
2. *MKL_PATH*: for cholesky, this EV is specifically for Cholesky kernel. Since we call to MKL functions in it.
3. *OPENCV_PATH*: for hog. Hog application needs OpenCV library to work, which is already comprised in its own folder. Hence, you can either set this EV to *tdg-benchs/hog/lib* or to your own opencv library folder.

Secondly, run `make` in the root folder of the current repository

Most applications have their corresponding runtime libraries set at compile time with rpath.
If not, please set the correct the library path by setting *LD_LIBRARY_PATH*.

### For NAS Benchmarks:
Access to the nas-omp folder and follow the instructions prompted by `make`. We 
need to specify the benchmark and the size to build. 