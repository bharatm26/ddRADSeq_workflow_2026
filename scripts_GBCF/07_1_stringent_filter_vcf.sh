#!/bin/bash
#
# Ensure conda is active
conda activate /home/bmishra2/anaconda3/envs/env_radseq

# 1. Define input directory and output directory
INPUT_DIR="../results/merged"
OUT_DIR="../results/processed_vcfs"
mkdir -p "$OUT_DIR"

# 2. Loop through all VCF files in the input directory
for myvcf in "$INPUT_DIR"/*.vcf.gz; do

    # Get the base name of the file
    base=$(basename "$myvcf" .vcf.gz)
    echo "======================================================="
    echo "Processing: $base"
    echo "======================================================="

    prefix="$OUT_DIR/$base"

    # A. Calculate INITIAL individual missingness
    vcftools --gzvcf "$myvcf" --missing-indv --out "${prefix}_initial"

    # B. Identify samples with over 90% genotypes missing
    tail -n +2 "${prefix}_initial.imiss" | awk '$5>0.9' | cut -f1 > "${prefix}_failed_90.rm"
    echo "Identified $(wc -l < ${prefix}_failed_90.rm) samples with >90% missingness."

    # C. Apply core quality filters (DP 10, GQ 20, MAF 0.05, mm 0.8)
    # This creates a high-confidence biallelic SNP set
    vcftools --gzvcf "$myvcf" \
        --remove "${prefix}_failed_90.rm" \
        --maf 0.05 \
        --max-missing 0.6 \
        --remove-indels \
        --max-alleles 2 \
        --min-alleles 2 \
        --minDP 5 \
        --minGQ 15 \
        --recode --recode-INFO-all --out "${prefix}_quality"

    # D. Final Filter: Remove samples with over 50% genotypes missing on pruned set
    tail -n +2 "${prefix}_unlinked.imiss" | awk '$5>0.5' | cut -f1 > "${prefix}_failed_50.rm"
    echo "Removing $(wc -l < ${prefix}_failed_50.rm) additional samples with >50% missingness."

    vcftools --vcf "${prefix}_quality.recode.vcf" \
        --remove "${prefix}_failed_50.rm" \
        --recode --recode-INFO-all --out "${prefix}_final_ancestry"

    # G. Compression and Indexing
    bgzip -c "${prefix}_final_ancestry.recode.vcf" > "${prefix}_final_ancestry.vcf.gz"
    tabix -p vcf "${prefix}_final_ancestry.vcf.gz"

    echo "DONE: ${prefix}_final_ancestry.vcf.gz"
done

echo "All tasks complete!"
