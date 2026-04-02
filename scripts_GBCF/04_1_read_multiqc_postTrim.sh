#!/bin/bash
#
# load the bio/2.0 module from CRC or intall fastqc

#module load bio/2.0
conda activate /home/bmishra2/anaconda3/envs/env_radseq

# --- Configuration ---
input_dir="../results/QC/trimmed" # MultiQC often searches results directories

multiqc_results_dir="../results/multiqc_trimmed"       # Subdirectory for MultiQC report
multiqc_report_name="multiqc_report_PostTrim.html"    # Name of the generated HTML report

# --- Script Start ---
echo -e "\n--- Running MultiQC ---"

# 1. Prepare MultiQC output directory
echo "Preparing MultiQC results directory: '$multiqc_results_dir'"
mkdir -p "$multiqc_results_dir" || { echo "Error: Could not create MultiQC results directory '$multiqc_results_dir'. Exiting."; exit 1; }

# 2. Check if the input directory for MultiQC exists
if [ ! -d "$input_dir" ]; then
    echo "Error: MultiQC search directory '$input_dir' not found. Please ensure it exists and contains QC output."
    exit 1
fi

# 3. Run MultiQC
echo "Running MultiQC on data in '$input_dir' and its subdirectories..."
# MultiQC will search the provided directories for compatible log files
multiqc "$input_dir" -o "$multiqc_results_dir" -n "$multiqc_report_name" --force

