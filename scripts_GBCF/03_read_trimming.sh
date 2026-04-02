#!/bin/bash

# Load the bio/2.0 module (assuming fastp is available here)
conda activate /home/bmishra2/anaconda3/envs/env_radseq

# Configuration (adjust paths as needed)
input_dir="../results/demuxed_seq"
fastp_results_dir="../results/trimming"

# Define full paths for all output directories

# Main script log file (all echoes from this script will go here)
mkdir -p "$fastp_results_dir" # Create output directory if it doesn't exist

# Loop through all forward raw FASTQ files
for infile in ${input_dir}/*.1.fq.gz; do
  base=$(basename "${infile}" .1.fq.gz)
  fq1_in="${infile}"
  fq2_in="${input_dir}/${base}.2.fq.gz"
  fq1_out="${fastp_results_dir}/${base}_1.trim.fq.gz"
  fq2_out="${fastp_results_dir}/${base}_2.trim.fq.gz"
  html_report="${fastp_results_dir}/${base}.fastp.html"
  
  echo "Processing sample: ${base}"

  # Run fastp command
  fastp \
    -i "${fq1_in}" \
    -I "${fq2_in}" \
    -o "${fq1_out}" \
    -O "${fq2_out}" \
    --html "${html_report}" \
    --thread 24 \
    --detect_adapter_for_pe
    echo "  fastp trimming complete for ${base}."

done # End of per-sample loop
