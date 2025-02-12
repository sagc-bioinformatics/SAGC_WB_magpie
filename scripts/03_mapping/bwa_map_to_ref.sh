#!/bin/bash

REFERENCE="../../downloads/reference/GCA_013399875.1_ASM1339987v1_genomic.fna.gz"

FQPATH="../../downloads/samples/"

R1=$FQPATH/"SS_Muscle_S6_R1_001_subsample.fastq.gz"
R2=$FQPATH/"SS_Muscle_S6_R2_001_subsample.fastq.gz"

bwa mem $REFERENCE $R1 $R2 > SS_alignment.sam
