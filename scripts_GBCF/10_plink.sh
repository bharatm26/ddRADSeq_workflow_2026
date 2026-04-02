#!/bin/bash
#
# Activate environment
conda activate /home/bmishra2/anaconda3/envs/env_radseq

# 1. Configuration
# readlink -f gets the absolute path so the script doesn't break after 'cd'
INPUT_VCF=$(readlink -f "../results/filtered_vcf/merged_final.vcf.gz") 
OUT_DIR="../results/admixture"
BASE_NAME="Mytilus_structure"

mkdir -p "$OUT_DIR"
cd "$OUT_DIR"

echo "-------------------------------------------------------"
echo "Step 1: Converting VCF to PLINK BED format"
echo "-------------------------------------------------------"

plink2 --vcf "$INPUT_VCF" \
    --set-all-var-ids '@:#' \
    --allow-extra-chr \
    --make-bed \
    --out "$BASE_NAME"

# The 'sed' command renames scaffolds to 'chrUn' so structure.py doesn't crash
echo "Renaming scaffolds in .bim file for compatibility..."
sed -i 's/^[^\t]*/chrUn/' "${BASE_NAME}.bim"

echo "PLINK conversion complete. Files located in $OUT_DIR"
