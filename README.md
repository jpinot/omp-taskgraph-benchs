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

A build script named `run_benchs.sh` is provided to automate the execution of the benchmarks. For running on MareNostrum 5 (or any SLURM-based HPC system), the script has been extended to correctly set up the environment(**NEED LIB PATH UPDATE**):

```bash
#!/bin/bash
#SBATCH --job-name=omp-tdg-benchmarks
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=125
#SBATCH --time=02:00:00
#SBATCH --error=error.txt
#SBATCH --partition=debug
#SBATCH --exclusive
module load mkl
module load gcc/13.2.0

export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/home/bsc/bsc477298/workspace/tdg-benchs/clang-x86--0bd2e96cb896/lib/x86_64-unknown-linux-gnu/
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/home/bsc/bsc477298/workspace/tdg-benchs/hog/lib/

```

## How to plot

```python
import pandas as pd
import matplotlib.pyplot as plt
import seaborn as sns
import sys
import os
import numpy as np

def generate_cholesky_heatmap(file_path):
    """
    Generates a heatmap of Cholesky decomposition speedup, calculated as
    time(vanilla) / time(record) for corresponding parameters, from a CSV file.

    Args:
        file_path (str): The path to the CSV file containing the data.
    """

    if not os.path.exists(file_path):
        print(f"Error: File not found at '{file_path}'")
        return

    try:
        df = pd.read_csv(file_path)
    except Exception as e:
        print(f"Error reading CSV file '{file_path}': {e}")
        return

    unique_tests = df['test'].unique()

    if not unique_tests.tolist():
        print("No unique 'test' values found in the CSV. Cannot generate plots.")
        return


    for test_name in unique_tests:
        print(f"\nGenerating heatmap for test: {test_name}")

        current_test_df = df[df['test'] == test_name]
        vanilla_df = current_test_df[current_test_df['type'] == 'vanilla']
        record_df = current_test_df[current_test_df['type'] == 'record']

        if vanilla_df.empty or record_df.empty:
            print(f"Skipping {test_name}: Both 'vanilla' and 'record' types are required for speedup calculation, but one or both are missing.")
            continue


        average_time_vanilla = vanilla_df.groupby(['number_of_blocks', 'threads'])['time'].mean().reset_index()
        average_time_vanilla = average_time_vanilla.rename(columns={'time': 'time_vanilla'})


        average_time_record = record_df.groupby(['number_of_blocks', 'threads'])['time'].mean().reset_index()
        average_time_record = average_time_record.rename(columns={'time': 'time_record'})


        merged_df = pd.merge(average_time_vanilla, average_time_record,
                             on=['number_of_blocks', 'threads'], how='inner')


        if merged_df.empty:
            print(f"Skipping {test_name}: Merged DataFrame is empty. No common 'number_of_blocks' and 'threads' combinations between vanilla and record data for this test.")
            continue


        merged_df['speedup'] = merged_df['time_vanilla'] / merged_df['time_record']


        pivot_table = merged_df.pivot(index='number_of_blocks', columns='threads', values='speedup')


        desired_blocks_order = [400, 576, 784, 1024]
        actual_blocks_in_data = sorted(pivot_table.index.unique())

        final_blocks_order = [b for b in desired_blocks_order if b in actual_blocks_in_data]
        for b in actual_blocks_in_data:
            if b not in final_blocks_order:
                final_blocks_order.append(b)

        final_blocks_order = sorted(final_blocks_order, reverse=True)
        pivot_table = pivot_table.reindex(final_blocks_order)

        ordered_threads = [8, 16, 24, 32, 48]
        columns_to_keep = [col for col in ordered_threads if col in pivot_table.columns]

        if not columns_to_keep:
            print(f"Skipping {test_name}: No matching thread columns found in the pivot table after reordering. Cannot create heatmap.")
            continue

        pivot_table = pivot_table[columns_to_keep]

        ##### print true speedup
        min_time_vanilla = vanilla_df.groupby(['number_of_blocks'])['time'].min().reset_index()
        min_time_vanilla = min_time_vanilla.rename(columns={'time': 'min_time_vanilla'})
        min_time_record = record_df.groupby(['number_of_blocks'])['time'].min().reset_index()
        min_time_record = min_time_record.rename(columns={'time': 'min_time_record'})

        merged_df = pd.merge(min_time_vanilla, min_time_record,
                             on=['number_of_blocks'], how='inner')

        if merged_df.empty:
            print(f"Skipping {test_name}: Merged DataFrame is empty. No common 'number_of_blocks' combinations between vanilla and record data for this test.")
            continue

        merged_df['speedup'] = merged_df['min_time_vanilla'] / merged_df['min_time_record']

        merged_df = merged_df.sort_values(by='number_of_blocks')

        for index, row in merged_df.iterrows():
            print(f"num of blocks: {int(row.number_of_blocks)} true_speedup: {row.speedup}");
        #####  end print true speedup

        valid_values = pivot_table.values[~np.isnan(pivot_table.values)]
        if valid_values.size == 0:
            print(f"Skipping {test_name}: The final pivot table contains no valid numerical data to plot (all NaN or empty).")
            continue

        vmin = 1.0 # Minimum speedup
        vmax = 6.0 # Maximum speedup

        plt.figure(figsize=(7, 5)) # Adjust figure size to match image aspect ratio
        ax = sns.heatmap(pivot_table, annot=True, fmt=".2f", cmap="Greens", cbar=False,
                         linewidths=.5, linecolor='lightgray', square=True,
                         vmin=vmin, vmax=vmax,
                         annot_kws={"fontsize": 14}) # <--- Add this line and adjust the number

        label_fontsize = 14 # Adjust as needed
        title_fontsize = 16 # Adjust as needed

        ax.set_ylabel('Number_of_blocks', rotation=90, ha='center', va='center', labelpad=20, fontsize=label_fontsize)
        ax.set_xlabel('Number_of_threads', labelpad=20, fontsize=label_fontsize)
        ax.set_title(f'{test_name.capitalize()} Speedup (Vanilla/Record)', y=1.05, fontsize=title_fontsize)

        ax.tick_params(axis='y', rotation=0, labelsize=label_fontsize)
        ax.tick_params(axis='x', labelsize=label_fontsize) # Also set x-axis tick label size
        plt.yticks(rotation=0)
        plt.tight_layout()
        plt.show()

if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("Usage: python your_script_name.py <path_to_csv_file>")
        sys.exit(1)
    csv_file_path = sys.argv[1]
    generate_cholesky_heatmap(csv_file_path) 
```
