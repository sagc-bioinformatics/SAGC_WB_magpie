#!/bin/bash

# Sets up the environment for tools to be used 

# Add and set channels to collect packages from
conda config --add channels conda-forge
conda config --add channels bioconda
conda config --add channels defaults
conda config --set channel_priority strict

# Install from environment file
conda env create -f environment.yml

# Activates the environment
conda activate magpac

# Verifies the packages are installed correctly
conda list

# Checks the current environment situation
conda config --show
