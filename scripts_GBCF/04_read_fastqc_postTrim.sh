#!/bin/bash

# load the bio/2.0 module from CRC or conda environment or intall fastqc

conda activate /home/bmishra2/anaconda3/envs/env_radseq

# --- Configuration ---
# Set default input and results directories.
input_dir="../results/trimming"

fastqc_results_dir="../QC/trimmed"

# 1. Prepare output directory
mkdir -p ../results/QC/trimmed

# 2. Run FastQC directly from the input directory, outputting to the designated results folder
cd "$input_dir" || { echo "Error: Could not change to input directory '$input_dir'. Exiting."; exit 1; }

# FastQC will place its .zip and .html files directly into fastqc_results_dir
fastqc -o "$fastqc_results_dir" *.trim.fq.gz*
