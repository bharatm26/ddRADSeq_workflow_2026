#!/bin/bash
#
source "$(conda info --base)/etc/profile.d/conda.sh"
conda activate /home/bmishra2/anaconda3/envs/pixy

mkdir -p ../results/pixy/

# Create a clean popmap (no header, only samples present in the VCF)
VCF_SAMPLES=$(zgrep "^#CHROM" ../results/filtered_vcf/merged_final.vcf.gz | tr '\t' '\n' | tail -n +10)
tail -n +2 ../raw/popMap_geno.txt | awk -v samples="$VCF_SAMPLES" '
BEGIN { split(samples, arr, "\n"); for (i in arr) valid[arr[i]]=1 }
{ if ($1 in valid) print $0 }
' > ../results/pixy/popmap_pixy.txt

# Nucleotide diversity (use small window size to fit RAD contigs)
pixy --populations ../results/pixy/popmap_pixy.txt --vcf ../results/filtered_vcf/merged_final.vcf.gz --stats pi --n_cores 16 --output_prefix merged_pi --output_folder ../results/pixy/ --window_size 10000 --bypass_invariant_check
