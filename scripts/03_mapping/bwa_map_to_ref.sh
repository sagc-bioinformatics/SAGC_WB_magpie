#!/bin/bash

REFERENCE="../../data/reference/GCA_013399875.1_ASM1339987v1_genomic.fna.gz"

FQPATH="../../data/samples/"

R1=$FQPATH/"AA_Muscle_S4_R1_001_subsample.fastq.gz"
R2=$FQPATH/"AA_Muscle_S4_R2_001_subsample.fastq.gz"

bwa mem $REFERENCE $R1 $R2 > AA_alignment.sam
