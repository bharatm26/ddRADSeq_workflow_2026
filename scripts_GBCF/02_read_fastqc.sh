#!/bin/bash

# load the bio/2.0 module from CRC or conda environment or intall fastqc

#module load bio/2.0

conda activate /home/bmishra2/anaconda3/envs/env_radseq

# --- Configuration ---
# Set default input and results directories.

input_dir="../results/demuxed_seq/"
results_base_dir="../results"
#fastqc_output_subdir="QC/UDP22" # Specific subdirectory for FastQC results


# Define the full path for FastQC specific results
fastqc_results_dir="../QC/PreTrim"

# 1. Prepare output directory
mkdir -p ../results/QC
mkdir -p ../results/QC/PreTrim


# 2. Run FastQC directly from the input directory, outputting to the designated results folder
cd "$input_dir" || { echo "Error: Could not change to input directory '$input_dir'. Exiting."; exit 1; }

# FastQC will place its .zip and .html files directly into fastqc_results_dir
fastqc -o "$fastqc_results_dir" *.fq*
