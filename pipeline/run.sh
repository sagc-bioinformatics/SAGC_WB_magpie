#!/bin/bash

module load nextflow
module load fastp

nextflow run pipeline.nf \
    --outdir='outs' \
    --samples='../downloads/samples/*R[1,2]*.fastq.gz' \
    --genome='../downloads/reference/GCA_013399875.1_ASM1339987v1_genomic.fna.gz' \
    --annotation='../downloads/reference/GCA_013399875.1_ASM1339987v1_genomic.gtf.gz' \
    -resume


