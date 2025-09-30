# =========================
# Author: Md Abrar Faiyaj
# Project: Genome Analysis of Yeast
# Date: 10/1/2025
# =========================

# Load packages
library(BSgenome)
library(BSgenome.Scerevisiae.UCSC.sacCer3)
library(Biostrings)
library(GenomicRanges)
library(TxDb.Scerevisiae.UCSC.sacCer3.sgdGene)
library(ggplot2)
library(dplyr)

# Load genome & annotation
yeast_genome <- BSgenome.Scerevisiae.UCSC.sacCer3
yeast_genome
txdb <- TxDb.Scerevisiae.UCSC.sacCer3.sgdGene
txdb

# Extract CDS annotation
cds_regions <- cdsBy(txdb, by = "tx")
cds_regions
cds_all <- unlist(cds_regions)
cds_all

# Chromosome list
chrom_names <- seqnames(yeast_genome)
chrom_names
# Store results
all_results <- data.frame()
all_results
# Loop through chromosomes
for (chr in chrom_names) {
  cat("Processing", chr, "...\n")
  
 # Whole chromosome sequence
  chr_seq <- yeast_genome[[chr]]
  chr_range <- GRanges(seqnames = chr, ranges = IRanges(1, length(chr_seq)))
  chr_seq
  chr_range
# CDS for this chromosome
  cds_chr <- cds_all[seqnames(cds_all) == chr]
  cds_chr
  if (length(cds_chr) > 0) {
    cds_chr_merged <- reduce(cds_chr)
    coding_seq <- getSeq(yeast_genome, cds_chr_merged)
    noncoding_ranges <- setdiff(chr_range, cds_chr_merged)
    noncoding_seq <- getSeq(yeast_genome, noncoding_ranges)
  } else {
    coding_seq <- DNAStringSet()
    noncoding_seq <- DNAStringSet(chr_seq)
  }
  
 # Compute stats
  coding_gc <- if (length(coding_seq) > 0) mean(letterFrequency(coding_seq, "GC", as.prob = TRUE)) else NA
  noncoding_gc <- if (length(noncoding_seq) > 0) mean(letterFrequency(noncoding_seq, "GC", as.prob = TRUE)) else NA
  
  coding_bases <- sum(width(coding_seq))
  noncoding_bases <- sum(width(noncoding_seq))
  
  tmp <- data.frame(
    Chromosome = chr,
    Region = c("Coding", "Non-coding"),
    Bases = c(coding_bases, noncoding_bases),
    GC_Content = c(coding_gc, noncoding_gc)
  )
  
  all_results <- rbind(all_results, tmp)
}
all_results
# =========================
# Save results
# =========================
dir.create("results", showWarnings = FALSE)
write.csv(all_results, "results/yeast_coding_vs_noncoding_all_chr.csv", row.names = FALSE)

# =========================
# Visualization
# =========================

# 1. Barplot: GC% per chromosome
p1 <- ggplot(all_results, aes(x = Chromosome, y = GC_Content, fill = Region)) +
  geom_bar(stat = "identity", position = "dodge") +
  ylim(0,1) +
  labs(title = "GC Content in Coding vs Non-coding Regions (Yeast Genome)",
       y = "GC Content (fraction)", x = "Chromosome") +
  theme_minimal(base_size = 14) +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))
ggsave("results/GCcontent_per_chromosome.png", plot = p1, width = 8, height = 5)
p1
# 2. Genome-wide pie chart (bases) with percentages + white background
genome_summary <- all_results %>%
  group_by(Region) %>%
  summarise(TotalBases = sum(Bases), .groups = "drop") %>%
  mutate(Fraction = TotalBases / sum(TotalBases),
         Label = paste0(Region, " (", round(Fraction*100, 1), "%)"))
genome_summary
p2 <- ggplot(genome_summary, aes(x = "", y = Fraction, fill = Region)) +
  geom_col(width = 1, color = "white") +
  coord_polar(theta = "y") +
  labs(title = "Genome Composition: Coding vs Non-coding") +
  theme_void(base_size = 14) +
  theme(panel.background = element_rect(fill = "white", color = "white")) +
  geom_text(aes(label = Label), position = position_stack(vjust = 0.5), color = "black")
ggsave("results/genome_composition_pie.png", plot = p2, width = 6, height = 6, bg = "white")
p2
# 3. GC% genome-wide (avg per region) with full title showing
avg_gc <- all_results %>%
  group_by(Region) %>%
  summarise(Mean_GC = mean(GC_Content, na.rm = TRUE))

p3 <- ggplot(avg_gc, aes(x = Region, y = Mean_GC, fill = Region)) +
  geom_bar(stat = "identity", width = 0.6) +
  ylim(0,1) +
  labs(title = "Average GC Content: Coding vs Non-coding (Genome-wide)",
       y = "GC Content (fraction)", x = "") +
  theme_minimal(base_size = 14) +
  theme(plot.title = element_text(hjust = 0.5, size = 16, margin = margin(t = 20, b = 20)))
ggsave("results/GCcontent_genomewide.png", plot = p3, width = 7, height = 5)
p3

