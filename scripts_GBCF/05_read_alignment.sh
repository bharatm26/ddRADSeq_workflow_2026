#!/bin/bash
#
# Load the required bioinformatics module
# This command is specific to environments like CRC
#module load bio/2.0
conda activate /home/bmishra2/anaconda3/envs/env_radseq

# --- Configuration ---
# Genome file name (must be unzipped .fasta in reference_dir)

THREADS=64

genome=/home/bmishra2/Documents/2025/Dev/radseq/ddRAD_analysis_workflow/blue_mussel/fasta/GCF_963676685.1_xbMytEdul2.2_genomic.fasta

bwa index $genome

cd ../results

mkdir -p bam

for fq1 in ../results/trimming/*_1.trim.fq.gz
    do
    echo "working with file $fq1"

    base=$(basename $fq1 _1.trim.fq.gz)
    echo "base name is $base"

    fq1=../results/trimming/${base}_1.trim.fq.gz
    fq2=../results/trimming/${base}_2.trim.fq.gz
    bam=../results/bam/${base}.bam
    sorted_bam=../results/bam/${base}.sorted.bam
    rg_header="@RG\tID:${base}\tSM:${base}\tPL:ILLUMINA"

    bwa mem $genome -t $THREADS -R "$rg_header" $fq1 $fq2 | \
    samtools sort -@ $THREADS -o $sorted_bam -
    samtools index $sorted_bam
    done
