#!/bin/bash

# Move to downloads directory
cd ../downloads

# Change to downloads folder and Download the B10K assembly from NCBI 
curl -O https://ftp.ncbi.nlm.nih.gov/genomes/all/GCA/013/399/875/GCA_013399875.1_ASM1339987v1/GCA_013399875.1_ASM1339987v1_genomic.fna.gz

# Change to downloads folder and Download B10K annotation from NCBI
curl -O https://ftp.ncbi.nlm.nih.gov/genomes/all/GCA/013/399/875/GCA_013399875.1_ASM1339987v1/GCA_013399875.1_ASM1339987v1_genomic.gtf.gz
