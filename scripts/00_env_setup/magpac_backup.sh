#!/bin/bash

# Sets up the environment for tools to be used 

# Add and set channels to collect packages from
conda config --add channels conda-forge
conda config --add channels bioconda
conda config --add channels defaults
conda config --set channel_priority strict

# The latest version of the tools, as of 2025/02/12
conda create -n magpac kraken2=2.1.3 trimmomatic=0.39 cutadapt=5.0 bwa-mem2=2.2.1 samtools=1.21 gatk4=4.6.1.0

# Activates the environment
conda activate magpac

# Verifies the packages are installed correctly
conda list

# Checks the current environment situation
conda config --show
