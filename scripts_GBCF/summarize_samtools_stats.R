# This script summarizes all samtools stats files in the results/bam directory
# and outputs a summary table for inclusion in the alignment section of the report.

library(dplyr)

bam_dir <- "/home/bmishra2/Documents/2026/projects/ddRADSeq_workflow_2026/results/bam"
stat_files <- list.files(bam_dir, pattern = "*.sorted.stats$", full.names = TRUE)


parse_stats <- function(file) {
  lines <- readLines(file)
  sample <- sub(".sorted.stats$", "", basename(file))
  get_sn_value <- function(pattern) {
    line <- grep(pattern, lines, value = TRUE)
    if (length(line) == 0) return(NA)
    as.numeric(gsub(".*:\\t", "", line))
  }
  total_reads <- get_sn_value("raw total sequences")
  mapped_reads <- get_sn_value("reads mapped:")
  avg_length <- get_sn_value("average length")
  pct_mapped <- if (!is.na(total_reads) && !is.na(mapped_reads) && total_reads > 0) {
    round(100 * mapped_reads / total_reads, 2)
  } else {
    NA
  }
  data.frame(Sample = sample, Total_Reads = total_reads, Mapped_Reads = mapped_reads, Percent_Mapped = pct_mapped, Avg_Length = avg_length)
}

stats_list <- lapply(stat_files, parse_stats)
all_stats <- bind_rows(stats_list)
write.csv(all_stats, file = file.path(bam_dir, "samtools_stats_summary.csv"), row.names = FALSE)
print(head(all_stats))
