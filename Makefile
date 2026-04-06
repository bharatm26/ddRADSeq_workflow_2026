# Minimal Makefile wrapper to run the workflow scripts in order.
# Usage:
#   make env         # create conda env from environment.yml
#   make all         # run entire processing pipeline (scripts run in order)

.PHONY: env all help alignment variants filter

ENV_FILE=environment.yml
ENV_NAME=env_radseq

help:
	@echo "Makefile targets: env, env-pixy, env-structure, all, alignment, variants, filter"

env:
	@echo "Creating conda environment $(ENV_NAME) from $(ENV_FILE)"
	conda env create -f $(ENV_FILE) || echo "If environment exists, activate with: conda activate $(ENV_NAME)"

env-pixy:
	@echo "Creating conda environment pixy from environment-pixy.yml"
	conda env create -f environment-pixy.yml || echo "If environment exists, activate with: conda activate pixy"

env-structure:
	@echo "Creating conda environment structure from environment-structure.yml"
	conda env create -f environment-structure.yml || echo "If environment exists, activate with: conda activate structure"

all: alignment variants filter

alignment:
	@echo "Running trimming + alignment steps"
	bash scripts_GBCF/00_remove_spacers.sh || exit 1
	bash scripts_GBCF/01_process_radtag_1.sh || exit 1
	bash scripts_GBCF/01_process_radtag_2.sh || exit 1
	bash scripts_GBCF/01_process_radtag_3.sh || exit 1
	bash scripts_GBCF/02_read_fastqc.sh || exit 1
	bash scripts_GBCF/02_1_read_multiqc_PreTrim.sh || exit 1
	bash scripts_GBCF/03_read_trimming.sh || exit 1
	# Run post-trimming QC before alignment
	bash scripts_GBCF/04_read_fastqc_postTrim.sh || exit 1
	bash scripts_GBCF/04_1_read_multiqc_postTrim.sh || exit 1
	bash scripts_GBCF/05_read_alignment.sh || exit 1

variants:
	@echo "Running variant calling"
	bash scripts_GBCF/06_variant_call.sh || exit 1

filter:
	@echo "Running VCF filtering"
	bash scripts_GBCF/07_vcf_filter_relaxed.sh || exit 1

