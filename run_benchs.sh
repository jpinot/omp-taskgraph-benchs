#!/bin/bash

ITERATIONS=64
THREADS=(8 16 24 32 48)

NBODY_PARTICLES=(4096 2048 1024 512)
CHOLESKY_BLOCKS=(20 24 28 32)
HEAT_BLOCKS=(32 36 40 44)
AXPY_VECTORS=(4096 8192 16384 32768 65536)
DOT_VECTORS=(4 8 16 32 64)
NBLOCKS=(1 2 3 4)
executables=(vanilla for record serial)

export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/usr/clang-x86/lib/x86_64-unknown-linux-gnu/

run_with_threads() {
  local cmd=$1
  for t in "${THREADS[@]}"; do
    echo "Running: OMP_PROC_BIND='close' OMP_NUM_THREADS=$t $cmd"
    OMP_PROC_BIND='close' OMP_NUM_THREADS=$t bash -c "$cmd"
  done
}

echo "--> axpy"
for exe_type in "${executables[@]}"; do
  exe="./axpy/axpy_$exe_type"
  for v in "${AXPY_VECTORS[@]}"; do
    run_with_threads "$exe 134217728 $v $ITERATIONS"
  done
done

echo "--> dot"
for exe_type in "${executables[@]}"; do
  exe="./dotp/dot_product_$exe_type"
  for c in "${DOT_VECTORS[@]}"; do
    run_with_threads "$exe 131072 $c $ITERATIONS"
  done
done

echo "---> nbody"
for exe_type in "${executables[@]}"; do
  exe="./nbody/nbody_$exe_type"
  for input_file in ./nbody/data/input/nbody_input.in_*; do
    particle_count=$(basename "$input_file" | cut -d'_' -f3)
    run_with_threads "$exe $input_file $particle_count $ITERATIONS"
  done
done

echo "--> hog"
for exe_type in "${executables[@]}"; do
  exe="./hog/personDetector_$exe_type"
  for n in "${NBLOCKS[@]}"; do
    run_with_threads "$exe ./hog/input_images/FullHD/otherImages/ 1 $ITERATIONS $n"
  done
done

echo "--> cholesky"
for exe_type in "${executables[@]}"; do
  exe="./cholesky/cholesky_$exe_type"
  for b in "${CHOLESKY_BLOCKS[@]}"; do
    run_with_threads "$exe $b $ITERATIONS"
  done
done

echo "--> heat"
for exe_type in "${executables[@]}"; do
  exe="./heat/heat_$exe_type"
  for b in "${HEAT_BLOCKS[@]}"; do
    run_with_threads "$exe ./heat/test.dat $b $ITERATIONS"
  done
done

echo "--> nas-omp"
for exe in ./nas-omp/bin/cg_taskloop*; do
    run_with_threads "$exe"
done

echo "=== All tests completed ==="
