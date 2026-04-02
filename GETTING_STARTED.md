# Getting started — ddRAD-Seq_workflow

Short guide for a new contributor. Follow the numbered scripts in order — do not skip or reorder without understanding downstream expectations.

## Prerequisites
- Install conda (Miniconda) or Mamba. Git and standard Unix tools available.

## Create all three conda environments

This workflow uses three separate environments. Create them all before running the pipeline:

```bash
# from repo root

# 1. Main analysis environment (scripts 00–08, 10, 12)
conda env create -f environment.yml
# or: make env

# 2. Pixy environment for nucleotide diversity (script 09)
conda env create -f environment-pixy.yml
# or: make env-pixy

# 3. Structure/admixture environment (script 11)
conda env create -f environment-structure.yml
# or: make env-structure
```

## Canonical script order (run these in sequence)

```bash
# ── Activate env_radseq ─────────────────────────────────────
conda activate env_radseq

# 00 - remove spacers / adapters (cutadapt)
bash scripts_GBCF/00_remove_spacers.sh

# 01 - process RADtags (may be split across 01_process_radtag_*.sh)
bash scripts_GBCF/01_process_radtag_1.sh
bash scripts_GBCF/01_process_radtag_2.sh
bash scripts_GBCF/01_process_radtag_3.sh

# 02 - pre-trimming QC (FastQC + MultiQC)
bash scripts_GBCF/02_read_fastqc.sh
bash scripts_GBCF/02_1_read_multiqc_PreTrim.sh

# 03 - read trimming (fastp)
bash scripts_GBCF/03_read_trimming.sh

# 04 - post-trimming QC (run BEFORE alignment)
bash scripts_GBCF/04_read_fastqc_postTrim.sh
bash scripts_GBCF/04_1_read_multiqc_postTrim.sh

# 05 - alignment (bwa mem + samtools)
bash scripts_GBCF/05_read_alignment.sh

# 06 - variant calling (bcftools mpileup + call)
bash scripts_GBCF/06_variant_call.sh

# 07 - filtering (default: relaxed)
bash scripts_GBCF/07_vcf_filter_relaxed.sh
# Optional stringent filtering:
# bash scripts_GBCF/07_1_stringent_filter_vcf.sh

# 08 - populations (Stacks populations + vcftools heterozygosity)
bash scripts_GBCF/08_populations.sh

# ── Switch to pixy environment ──────────────────────────────
conda activate pixy

# 09 - nucleotide diversity (pixy)
bash scripts_GBCF/09_pixy.sh

# ── Switch back to env_radseq ───────────────────────────────
conda activate env_radseq

# 10 - PLINK conversion (VCF → BED format for structure)
bash scripts_GBCF/10_plink.sh

# ── Switch to structure environment ─────────────────────────
conda activate structure

# 11 - admixture / fastSTRUCTURE
bash scripts_GBCF/11_admixture.sh

# ── Switch back to env_radseq for R analysis ────────────────
conda activate env_radseq

# 12 - downstream analysis (PCA, hybrid index, admixture plots)
#      Open scripts_GBCF/12_Downstream_Analysis.Rmd in RStudio
```

## Run a single numbered step
- To run only alignment (05):
```bash
conda activate env_radseq
bash scripts_GBCF/05_read_alignment.sh
```

- To run only pixy (09):
```bash
conda activate pixy
bash scripts_GBCF/09_pixy.sh
```

## Filtering choices
- Default (used in Makefile): `scripts_GBCF/07_vcf_filter_relaxed.sh` (DP≥3, GQ≥10, MAF≥0.01, max-missing 0.5).
- Use `scripts_GBCF/07_1_stringent_filter_vcf.sh` (DP≥5, GQ≥15, MAF≥0.05, max-missing 0.6) only for high-confidence downstream analyses; document thresholds when you do.

## Makefile targets
```bash
make env             # create env_radseq
make env-pixy        # create pixy
make env-structure   # create structure
make all             # run alignment + variants + filter (steps 00–07)
make alignment       # steps 00–05
make variants        # step 06
make filter          # step 07
```

## Tips & troubleshooting
- Scripts use absolute conda paths — update the `conda activate` lines if your environment paths differ.
- Inspect outputs under `results/` (subfolders: `demuxed_seq`, `QC`, `trimming`, `bam`, `merged`, `vcf`, `filtered_vcf`, `populations`, `pixy`, `admixture`, `downstream_plots`).
- If a step fails, check the terminal output and the corresponding `results/` folder for partial files.

## Where to read more
- Scripts: `scripts_GBCF/`
- Environment YAMLs: `environment.yml`, `environment-pixy.yml`, `environment-structure.yml`
- Downstream R analysis: `scripts_GBCF/12_Downstream_Analysis.Rmd`
