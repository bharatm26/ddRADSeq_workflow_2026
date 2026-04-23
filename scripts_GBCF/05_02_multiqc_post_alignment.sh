#!/bin/bash
# MultiQC post-alignment summary script
# Usage: bash 05_multiqc_post_alignment.sh

# Activate the appropriate conda environment
conda activate /home/bmishra2/anaconda3/envs/env_radseq

# --- Configuration ---
input_dir="../results/bam"  # Directory containing BAM files and alignment logs
multiqc_results_dir="../results/multiqc_alignment"  # Output directory for MultiQC report
multiqc_report_name="multiqc_report_alignment.html"  # Name of the generated HTML report

# --- Script Start ---
echo -e "\n--- Running MultiQC for post-alignment QC ---"

# 1. Prepare MultiQC output directory
echo "Preparing MultiQC results directory: '$multiqc_results_dir'"
mkdir -p "$multiqc_results_dir" || { echo "Error: Could not create MultiQC results directory '$multiqc_results_dir'. Exiting."; exit 1; }

# 2. Check if the input directory for MultiQC exists
if [ ! -d "$input_dir" ]; then
    echo "Error: MultiQC search directory '$input_dir' not found. Please ensure it exists and contains BAM and log files."
    exit 1
fi

# 3. Run MultiQC
echo "Running MultiQC on data in '$input_dir' and its subdirectories..."
multiqc "$input_dir" -o "$multiqc_results_dir" -n "$multiqc_report_name" --force

echo "MultiQC post-alignment report generated at: $multiqc_results_dir/$multiqc_report_name"
