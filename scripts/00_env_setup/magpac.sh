#!/bin/bash

# Sets up the environment for tools to be used 
conda env create -f environment.yml

# Activates the environment
conda activate magpac

# Verifies the packages are installed correctly
conda list

# Checks the current environment situation
conda config --show
