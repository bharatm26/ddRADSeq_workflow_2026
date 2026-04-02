#!/bin/bash
#
conda activate /home/bmishra2/anaconda3/envs/structure


# 1. Configuration
INPUT_VCF="../results/filtered_vcf/merged_final.vcf.gz" # Update to your latest filtered VCF
OUT_DIR="../results/admixture"
BASE_NAME="Mytilus_structure"
MAX_K=15

cd "$OUT_DIR"

#echo "Renaming scaffolds to chrUn for compatibility..."
#vim -c 'g/^[^#]/s/.\{-}\t/chrUn\t/' -c 'wq' "${BASE_NAME}.bim"

# Iterate through K values
for k in $(seq 1 $MAX_K); do
    echo "Processing K=$k..."
    
    # --input is the prefix of your PLINK files
    # --output is the prefix for result files
    # --full uses the variational Bayesian inference (default)
    structure.py \
        -K "$k" \
        --input="$BASE_NAME" \
        --output="${BASE_NAME}_K${k}" \
        --full \
        --seed=100
done

echo "-------------------------------------------------------"
echo "Model Selection (Choosing K)"
echo "-------------------------------------------------------"

# This identifies which K best explains the population structure
chooseK.py --input="$BASE_NAME" > "${BASE_NAME}_chooseK_results.txt"

echo "-------------------------------------------------------"
echo "Analysis Complete!"
echo "Check ${BASE_NAME}_chooseK_results.txt to find the optimal K."
echo "-------------------------------------------------------"
