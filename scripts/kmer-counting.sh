#!/bin/bash

# Quick method to count unique kmer sequences from a fastq file
# We will probably use Jellyfish instead of doing this manually

cat A.fastq |\
    awk 'NR%4==2 {k = 4; for(i=0; i<length-k; i++) print substr($0, i+1, k)}' |\
    sort | uniq -c | sort -nr