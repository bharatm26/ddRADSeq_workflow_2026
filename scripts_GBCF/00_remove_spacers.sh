#!/bin/bash
#
# activate conda env
conda activate /home/bmishra2/anaconda3/envs/env_radseq

# Navigate to the raw data directory
cd ../raw/ILMN_2328_HarkerBrent_ND_GBCF_PB_2875_Oct2024 || { echo "Directory not found"; exit 1; }

# 1. Create the conditional spacer file (add TAA to the end of each sequence)
# ---
echo "Creating conditional spacer file..."
awk '/^>/ {print $0} /^[^>]/ {print $0 "TAA"}' spacers_old.fa > spacers_with_TAA.fa
echo "Done."

# 2. Loop through paired-end files
# ---
# This glob finds the R1 files; we will infer the R2 files from these.
for r1_file in *R1_001.fastq.gz
do
    # Extract the base name (everything before _R1)
    sample_base=${r1_file%_R1*}
    
    # Define the corresponding R2 file
    r2_file="${sample_base}_R2_001.fastq.gz"

    # Check if R2 exists to avoid errors
    if [[ ! -f "$r2_file" ]]; then
        echo "Warning: R2 file for $sample_base not found. Skipping..."
        continue
    fi

    echo "--------------------------------------------"
    echo "Processing Sample: $sample_base"
    echo "--------------------------------------------"

    ####
    # 1) Split reads into matched and unmatched streams
    # cutadapt handles the demultiplexing/trimming
    ####
    echo "Running cutadapt..."
    cutadapt \
     -g file:spacers_with_TAA.fa \
     -e 0.1 \
     -o "${sample_base}_R2.matched.fq" \
     -p "${sample_base}_R1.matched.fq" \
     --untrimmed-output "${sample_base}_R2.unmatched.fq" \
     --untrimmed-paired-output "${sample_base}_R1.unmatched.fq" \
     "$r2_file" \
     "$r1_file" > "${sample_base}_spacer_split.log"

    ####
    # 2) Fix the matched R2 file
    # Prepend "TAA" to sequence and "III" to quality scores
    ####
    echo "Fixing R2 reads (restoring TAA)..."
    awk 'BEGIN{OFS="\n"} {
        header=$0; 
        if(getline seq <= 0) exit; 
        if(getline plus <= 0) exit; 
        if(getline qual <= 0) exit; 
        print header, "TAA"seq, plus, "III"qual
    }' "${sample_base}_R2.matched.fq" > "${sample_base}_R2.fixed.fq"

    ####
    # 3) Recombine and Compress
    # Merges the fixed-matched reads with the unmatched reads
    ####
    echo "Recombining and compressing..."
    
    cat "${sample_base}_R2.fixed.fq" "${sample_base}_R2.unmatched.fq" | gzip > "${sample_base}_R2_final.fastq.gz"
    cat "${sample_base}_R1.matched.fq" "${sample_base}_R1.unmatched.fq" | gzip > "${sample_base}_R1_final.fastq.gz"

    ####
    # 4) Cleanup
    ####
    echo "Cleaning up intermediate files for $sample_base..."
    rm "${sample_base}_R2.matched.fq" \
       "${sample_base}_R1.matched.fq" \
       "${sample_base}_R2.unmatched.fq" \
       "${sample_base}_R1.unmatched.fq" \
       "${sample_base}_R2.fixed.fq"

done

echo "--------------------------------------------"
echo "All samples processed successfully."
