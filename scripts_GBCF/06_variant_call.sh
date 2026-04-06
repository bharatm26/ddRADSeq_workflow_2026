#!/bin/bash
#
# Load environment
# module load bio/2.0
conda activate /home/bmishra2/anaconda3/envs/env_radseq

# --- Prevent Java Library Conflicts ---
#unset LD_LIBRARY_PATH
#export JAVA_HOME="/home/bmishra2/anaconda3/envs/env_radseq"

# --- Configuration ---
THREADS=64
genome=/home/bmishra2/Documents/2026/projects/ddRADSeq_workflow_2026/blue_mussel/fasta/GCF_963676685.1_xbMytEdul2.2_genomic.fasta

# Setup directories
cd ../results
mkdir -p merged vcf

merged_bam=../results/merged/merged.bam
merged_bcf=../results/merged/merged.bcf
merged_vcf=../results/merged/merged.vcf.gz
variants_stats=../results/merged/merged_variants.stats.out

# --- Step 1: GATK Clipping Loop ---
# We iterate over the sorted BAMs created in the previous script
for sorted_bam in ../results/bam/*.sorted.bam
do
    base=$(basename $sorted_bam .sorted.bam)
    echo "Clipping reads for $base"
    
    clipped_bam=../results/bam/${base}.clip.bam
    
    # GATK ClipReads
    gatk ClipReads \
        -I $sorted_bam \
        -O $clipped_bam \
        --cycles-to-trim "1-5" \
        --clip-representation WRITE_NS
done

# --- Step 2: Merging ---
# Create a list of all clipped BAM files for merging
echo "Merging all clipped BAM files..."
# Note: This gathers all files ending in .clip.bam
clip_list=$(ls ../results/bam/*.clip.bam)

samtools merge --threads $THREADS $merged_bam $clip_list

# --- Step 3: Variant Calling ---
echo "Calling variants..."

# Mpileup
bcftools mpileup -O b --threads $THREADS -q 20 -Q 10 -o $merged_bcf -f $genome $merged_bam

# Call
bcftools call --ploidy 2 -m -v -o $merged_vcf $merged_bcf

# Stats
bcftools stats $merged_vcf > $variants_stats

echo "Pipeline complete."
