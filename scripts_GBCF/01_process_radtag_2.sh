#!/bin/bash

# activate conda env
conda activate /home/bmishra2/anaconda3/envs/env_radseq

# This script processes RAD-seq data for demultiplexing.

# Define input files and output directory
# The -i gzfastq flag specifies the input format.
# -P indicates paired-end reads.
INPUT_R1="../raw/ILMN_2328_HarkerBrent_ND_GBCF_PB_2875_Oct2024/Mytilus_UDP24_S2_L002_R1_final.fastq.gz"
INPUT_R2="../raw/ILMN_2328_HarkerBrent_ND_GBCF_PB_2875_Oct2024/Mytilus_UDP24_S2_L002_R2_final.fastq.gz"
BARCODES="../raw/ILMN_2328_HarkerBrent_ND_GBCF_PB_2875_Oct2024/Barcode_UDP24.txt"
OUTPUT_DIR="../results/demuxed_seq/"

mkdir -p ../results/demuxed_seq
mkdir -p "$OUTPUT_DIR"

# Run the process_radtags command with all specified options
# -o specifies the output directory.
# -r, -c, and -q are various filtering flags.
# --renz_1 and --renz_2 specify the restriction enzymes used.

process_radtags -i gzfastq -P \
  -1 "$INPUT_R1" \
  -2 "$INPUT_R2" \
  -b "$BARCODES" \
  --inline_null \
  -o "$OUTPUT_DIR" \
  -r -c -q \
  --renz_1 ecoRI \
  --renz_2 mseI \
  --threads 64

echo "Demultiplexing complete. Output files are in $OUTPUT_DIR"
