#!/bin/bash
#
conda activate /home/bmishra2/anaconda3/envs/env_radseq

# 1. Define input directory and output directory
INPUT_DIR="../results/merged"
OUT_DIR="../results/filtered_vcf"
mkdir -p "$OUT_DIR"

# 2. Loop through all VCF files in the input directory
for myvcf in "$INPUT_DIR"/*.vcf.gz; do

    # Get the base name of the file
    base=$(basename "$myvcf" .vcf.gz)
    echo "======================================================="
    echo "Processing: $base"
    echo "======================================================="

    prefix="$OUT_DIR/$base"

    # STEP A: Calculate INITIAL individual missingness
    # This helps identify samples that basically failed sequencing
    vcftools --gzvcf "$myvcf" --missing-indv --out "${prefix}_initial"

    # STEP B: Identify samples with over 95% genotypes missing
    tail -n +2 "${prefix}_initial.imiss" | awk '$5>0.95' | cut -f1 > "${prefix}_failed_95.rm"
    echo "Samples removed due to >95% missingness: $(wc -l < ${prefix}_failed_95.rm)"

    # STEP C: Apply Core Quality Filters
    # Uses your relaxed parameters: MinDP 3, MinGQ 10, Max-Missing 0.5
    vcftools --gzvcf "$myvcf" \
        --remove "${prefix}_failed_95.rm" \
        --maf 0.01 \
        --max-missing 0.5 \
        --remove-indels \
        --max-alleles 2 \
        --min-alleles 2 \
        --minDP 3 \
        --minGQ 10 \
        --recode --recode-INFO-all --out "${prefix}_quality_filtered"

    # STEP D: Recalculate individual missingness on the quality-filtered set
    vcftools --vcf "${prefix}_quality_filtered.recode.vcf" --missing-indv --out "${prefix}_quality_filtered"

    # STEP E: Identify and remove samples with over 80% genotypes missing
    # You can change 0.5 to 0.8 here if you still find too few samples remain
    tail -n +2 "${prefix}_quality_filtered.imiss" | awk '$5>0.8' | cut -f1 > "${prefix}_failed_80.rm"
    echo "Samples removed due to >80% missingness: $(wc -l < ${prefix}_failed_80.rm)"

    # STEP F: Final Output Generation
    vcftools --vcf "${prefix}_quality_filtered.recode.vcf" \
        --remove "${prefix}_failed_80.rm" \
        --recode --recode-INFO-all --out "${prefix}_final"

    # STEP G: Compression and Indexing
    bgzip -c "${prefix}_final.recode.vcf" > "${prefix}_final.vcf.gz"
    tabix -p vcf "${prefix}_final.vcf.gz"

    # Optional: Clean up large intermediate .recode.vcf files
    rm "${prefix}_quality_filtered.recode.vcf" "${prefix}_final.recode.vcf"

    echo "Finished: ${prefix}_final.vcf.gz"
done

echo "Batch processing complete."
