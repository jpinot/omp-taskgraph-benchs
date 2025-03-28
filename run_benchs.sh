#!/bin/bash

ITERATIONS=64
THREADS=(8 16 24 32 48)

NBODY_PARTICLES=(4096 2048 1024 512)
CHOLESKY_BLOCKS=(400 576 784 1024)
HEAT_BLOCKS=(1024 1296 1600 1936)
DOT_VECTORS=(4096 8192 16384 32768)
AXPY_VECTORS=(4096 8192 16384 32768)
NBLOCKS=(1 2 3 4 5 6)
executables=(vanilla for record serial)

export LD_LIBRARY_PATH=/usr/clang-x86/lib/x86_64-unknown-linux-gnu/

run_with_threads() {
  local cmd=$1
  for t in "${THREADS[@]}"; do
    echo "Running: OMP_NUM_THREADS=$t $cmd"
    OMP_NUM_THREADS=$t $cmd
  done
}

echo "---> nbody"
for exe_type in "${executables[@]}"; do
  exe="./nbody/nbody_$exe_type"
  for input_file in ./nbody/data/input/nbody_input.in_*; do
    particle_count=$(basename "$input_file" | cut -d'_' -f3)
    run_with_threads "$exe $input_file $particle_count $ITERATIONS"
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

echo "--> dot"
for exe_type in "${executables[@]}"; do
  exe="./dotp/dot_product_$exe_type"
  for c in "${DOT_VECTORS[@]}"; do
    run_with_threads "$exe 131072 $c $ITERATIONS"
  done
done

echo "--> hog"
for exe_type in "${executables[@]}"; do
  exe="./hog/personDetector_$exe_type"
  for n in "${NBLOCKS[@]}"; do
    run_with_threads "$exe ./hog/input_images/FullHD/otherImages/ 10 $ITERATIONS $n"
  done
done

echo "--> axpy"
for exe_type in "${executables[@]}"; do
  exe="./axpy/axpy_$exe_type"
  for v in "${AXPY_VECTORS[@]}"; do
    run_with_threads "$exe $v $v $ITERATIONS"
  done
done

echo "--> nas-omp"
for exe in ./nas-omp/bin/*; do
    run_with_threads "$exe"
done

echo "=== All tests completed ==="
