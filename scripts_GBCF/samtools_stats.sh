#!/bin/bash
#
# Load the required bioinformatics module
# This command is specific to environments like CRC
#module load bio/2.0
conda activate /home/bmishra2/anaconda3/envs/env_radseq

# --- Configuration ---
# Genome file name (must be unzipped .fasta in reference_dir)
set -e

BAM_DIR="$(dirname "$0")/../results/bam"
OUTPUT_DIR="$BAM_DIR"

if ! command -v samtools &> /dev/null; then
    echo "Error: samtools is not installed or not in PATH."
    exit 1
fi

if [ ! -d "$BAM_DIR" ]; then
    echo "Error: BAM directory '$BAM_DIR' does not exist."
    exit 1
fi

shopt -s nullglob
BAM_FILES=("$BAM_DIR"/*.sorted.bam)
if [ ${#BAM_FILES[@]} -eq 0 ]; then
    echo "No sorted BAM files (*.sorted.bam) found in $BAM_DIR."
    exit 0
fi

for BAM in "${BAM_FILES[@]}"; do
    SAMPLE=$(basename "$BAM" .sorted.bam)
    OUTFILE="$OUTPUT_DIR/${SAMPLE}.sorted.stats"
    echo "Running samtools stats on $BAM..."
    samtools stats -@ 46 "$BAM" > "$OUTFILE"
    echo "Stats written to $OUTFILE"
done
echo "All samtools stats completed."
