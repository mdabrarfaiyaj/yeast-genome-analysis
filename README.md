# 🧬 Yeast Genome Analysis

This repository contains a **comprehensive analysis of the *Saccharomyces cerevisiae* (yeast) genome**, focusing on **coding vs non-coding regions** and **GC content**.  
The project uses **R and Bioconductor** packages to extract genomic annotations, compute base composition per chromosome, and visualize genome-wide patterns.

---

## 🚀 Features
- Extract coding vs non-coding sequences per chromosome
- Compute GC content for both regions
- Save results as CSV and PNG plots
- Visualize:
  - GC content per chromosome
  - Average genome-wide GC content
  - Genome composition pie chart

---

## 📦 Requirements

```R
install.packages("ggplot2")
install.packages("dplyr")

if (!requireNamespace("BiocManager", quietly = TRUE))
    install.packages("BiocManager")

BiocManager::install(c(
    "BSgenome",
    "BSgenome.Scerevisiae.UCSC.sacCer3",
    "Biostrings",
    "GenomicRanges",
    "TxDb.Scerevisiae.UCSC.sacCer3.sgdGene"
))
