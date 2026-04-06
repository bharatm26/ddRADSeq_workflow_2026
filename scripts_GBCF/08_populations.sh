#!/bin/bash
#
conda activate /home/bmishra2/anaconda3/envs/env_radseq

mkdir ../results/populations/

populations -O ../results/populations/ --popmap ../raw/popMap_geno.txt -V ../results/filtered_vcf/merged_final.vcf.gz --smooth -p 9 -f p_value -t 12 

# Heterozygosity
vcftools --gzvcf ../results/filtered_vcf/merged_final.vcf.gz --het --out ../results/filtered_vcf/heterozygous_merged  

#--structure --genepop --write-single-snp
