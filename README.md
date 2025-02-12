
# SAGC white-backed magpie project

## TODO

- [x] Set up git/github
- [x] Download existing B10K sequence / assembly data
- [x] Make branch for myself
- [ ] Set up jupyter notebook
- [-] Make plan for assembly / mapping of novel sequence data
  - [ ] Run jellyfish / GenomeScope to get estimated coverage stats
  - [ ] Map to existing B10K sequences, probably with bwa-mem2
        Estimate percentage match to black-backed magpie per sample 

- [ ] Make plans for presentations on the 20th
- [-] Create conda environment for reference mapping

### Mapping to a reference

- Install required tools
- Use tool like fastp or fastqc to filter reads by quality
- Do contamination detection (kraken2)
- Trim reads (remove adapter sequence) (trimmomatic, cutadapt)
- Identify reference, build an index for reference (bwa-mem2)
- Map to reference (bwa-mem2)
- Modify the output alignment files (samtools)
- Explore which reads have been assigned to which genes (IGV)
- Call variants within annotated genes (mutect2?) - generate vcf file


# Project log


### 12/02/25

- Restructured repository to make order of scripts clearer
- Created environment.yml file for tools to run locally
- Swapped from bwa-mem2 to bwa so that index building can fit within laptop memory


