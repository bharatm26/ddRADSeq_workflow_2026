# ddRAD-Seq_workflow

Small, reproducible bash workflow for ddRAD-Seq data processing and basic population analyses.

Highlights
- Canonical data flow: raw FASTQ -> spacer removal -> demultiplexing -> QC -> trimming -> post-trim QC -> alignment -> per-sample clipping & merge -> variant calling -> filtering -> downstream analyses (populations, pixy, PCA, admixture).
- Scripts are in `scripts_GBCF/` and must be run in numeric order (00 → 12). See `GETTING_STARTED.md` for a quick reference.

## Prerequisites
- Conda (Miniconda) or Mamba. Git and standard Unix tools.
- Three separate conda environments are used (see below).

## Conda environments

This workflow uses **three** conda environments. Create all of them before running the pipeline:

```bash
# 1. Main analysis environment (scripts 00–08, 10)
conda env create -f environment.yml
# or: make env

# 2. Pixy environment for nucleotide diversity (script 09)
conda env create -f environment-pixy.yml
# or: make env-pixy

# 3. Structure/admixture environment (script 11)
conda env create -f environment-structure.yml
# or: make env-structure
```

| Environment | YAML file | Env name | Used by | Key tools |
|---|---|---|---|---|
| Main | `environment.yml` | `env_radseq` | Scripts 00–08, 10, 12 | bwa, samtools, bcftools, gatk4, stacks, vcftools, cutadapt, fastqc, multiqc, fastp, plink2, R + Bioconductor |
| Pixy | `environment-pixy.yml` | `pixy` | Script 09 | pixy |
| Structure | `environment-structure.yml` | `structure` | Script 11 | faststructure, plink |

## Quick start (canonical script order)

Either run `make all` (Makefile wrapper for steps 00–07) or call the numbered scripts in order:

```bash
# ── env_radseq ──────────────────────────────────────────────

# 00: remove spacers / adapters
bash scripts_GBCF/00_remove_spacers.sh

# 01: process RADtags (demultiplexing)
bash scripts_GBCF/01_process_radtag_1.sh
bash scripts_GBCF/01_process_radtag_2.sh
bash scripts_GBCF/01_process_radtag_3.sh

# 02: pre-trimming QC
bash scripts_GBCF/02_read_fastqc.sh
bash scripts_GBCF/02_1_read_multiqc_PreTrim.sh

# 03: read trimming (fastp)
bash scripts_GBCF/03_read_trimming.sh

# 04: post-trimming QC (run BEFORE alignment)
bash scripts_GBCF/04_read_fastqc_postTrim.sh
bash scripts_GBCF/04_1_read_multiqc_postTrim.sh

# 05: alignment (bwa mem)
bash scripts_GBCF/05_read_alignment.sh

# 06: variant calling (bcftools mpileup + call)
bash scripts_GBCF/06_variant_call.sh

# 07: VCF filtering (default: relaxed)
bash scripts_GBCF/07_vcf_filter_relaxed.sh

# 08: populations (Stacks populations + heterozygosity)
bash scripts_GBCF/08_populations.sh

# ── pixy ────────────────────────────────────────────────────

# 09: nucleotide diversity (pixy)
bash scripts_GBCF/09_pixy.sh

# ── env_radseq ──────────────────────────────────────────────

# 10: PLINK conversion (VCF → BED for structure)
bash scripts_GBCF/10_plink.sh

# ── structure ───────────────────────────────────────────────

# 11: admixture / fastSTRUCTURE
bash scripts_GBCF/11_admixture.sh

# ── env_radseq (R) ─────────────────────────────────────────

# 12: downstream analysis (PCA, hybrid index, admixture plots)
#     Open scripts_GBCF/12_Downstream_Analysis.Rmd in RStudio
```

## Filtering guidance
- Default (used by `Makefile`): `scripts_GBCF/07_vcf_filter_relaxed.sh` (DP≥3, GQ≥10, MAF≥0.01, max-missing 0.5).
- Optional stringent filtering: `scripts_GBCF/07_1_stringent_filter_vcf.sh` (DP≥5, GQ≥15, MAF≥0.05, max-missing 0.6) — use for high-confidence downstream analyses and document the thresholds used.

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

## Directory structure

```
raw/                  # raw FASTQ files, barcodes, population maps
blue_mussel/fasta/    # reference genome (FASTA + BWA index)
scripts_GBCF/        # numbered analysis scripts
results/              # all outputs, organised by step
  demuxed_seq/        #   demultiplexed reads
  QC/                 #   FastQC reports
  trimming/           #   trimmed reads
  multiqc_PreTrim/    #   pre-trim MultiQC
  multiqc_trimmed/    #   post-trim MultiQC
  bam/                #   alignments
  merged/             #   merged BAMs
  vcf/                #   raw VCF
  filtered_vcf/       #   filtered VCF
  populations/        #   Stacks populations output
  pixy/               #   pixy output
  admixture/          #   PLINK + fastSTRUCTURE results
  downstream_plots/   #   R-generated plots (PCA, admixture, etc.)
```

## Quick troubleshooting
- Inspect outputs under `results/` (subfolders listed above).
- On failure, inspect console output and the corresponding `results/` directory for partial files.
- Scripts use absolute conda paths — update the `conda activate` lines if your environment paths differ.

## Citation

If you use this workflow, please cite it:

> Mishra, B. (2026). *ddRAD-Seq Workflow* [Software]. https://github.com/bmishra2/ddRADSeq_workflow_2026

A machine-readable citation file is included — see `CITATION.cff`.

## References

- **Stacks**: Catchen J. et al. (2013). Stacks: an analysis tool set for population genomics. *Molecular Ecology*, 22(11), 3124–3140. doi:[10.1111/mec.12354](https://doi.org/10.1111/mec.12354)
- **RAD_analysis_workflow**: Scheben A. RAD Analysis Workflow. https://github.com/ascheben/RAD_analysis_workflow
