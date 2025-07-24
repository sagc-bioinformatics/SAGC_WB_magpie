#!/bin/bash
# todo: original reference

module load htslib samtools bcftools mafft iq-tree

INPUTS=(
AA_Liver_S1
AA_Muscle_S4
MF_Liver_S2
MF_Muscle_S5
SS_Liver_S3
SS_Muscle_S6
)

# bgzip compressed reference
REFERENCE=~/SAGC/projects/MagpieSequencing_V350246760/SAGC_WB_magpie/downloads/reference/GCA_013399875.1_ASM1339987v1_genomic.fna.bgz
GTF=~/SAGC/projects/MagpieSequencing_V350246760/SAGC_WB_magpie/downloads/reference/GCA_013399875.1_ASM1339987v1_genomic.gtf.bgz

# Desired gene
GENE_SYMBOL=Mc1r

# Our outgroup
OUTGROUP="Gallus gallus"

# taxon to filter orthologous genes to
ORTHO_TAXON=Passeriformes

# get genomic region from gtf
# e.g. "VXAZ01001118.1:625174-627574"

REGION=$(zcat "$GTF" | awk -F'\t' -v gene="$GENE_SYMBOL" '$3=="gene" && $9 ~ "gene \"" gene "\"" { print $1":"$4"-"$5 }')
echo Region: $REGION
    
OUTS="${GENE_SYMBOL}_outs"
TEMPFILES="${OUTS}/tempfiles"
MSA="${OUTS}/msa"

THREADS=8

function setup {
    # Set up output dir
    mkdir -p $OUTS

    # setup temp dir
    mkdir -p $TEMPFILES
}

function get_consensus {
    
    sample=$1

    BAM="../${sample}.bam"
    SUBSET="$TEMPFILES/${sample}_subset.bam"
    VARIANTS="$TEMPFILES/${sample}.vcf"

    # Extract specific gene from bam file
    samtools view -b $BAM $REGION > $SUBSET

    # Pileup, output uncompressed bcf (-Ou), provide reference (reference.fasta), and bam
    # piped directly into bcftools call, -m (default multialelic caller) -v (variants only) -Ob (output binary compresed vcf)
    bcftools mpileup -Ou -f $REFERENCE $SUBSET | bcftools call --ploidy 2 -mv -Ou | bcftools filter -i 'QUAL >= 30 && DP >= 10 && MQ >= 30' -Ov -o $VARIANTS
    # Now that can be viewed directly in igv...

    # Compress variants and make index
    bgzip -c $VARIANTS > $VARIANTS.bgz
    tabix $VARIANTS.bgz

    # Get subset of reference | pipe to bcftools consensus, prefix with sample name
    samtools faidx $REFERENCE $REGION | bcftools consensus -p $sample $VARIANTS.bgz > $OUTS/${sample}_consensus.fa
}

function loop_bams {
    # Loop over each bam file and get the consensus gene sequence
    for sample in ${INPUTS[@]}; do
        echo $sample
        get_consensus $sample
    done
}

# Download orthologous bird gene fastas from ncbi
function download_ncbi {
    datasets download gene symbol $GENE_SYMBOL --include gene --ortholog $ORTHO_TAXON --filename "${GENE_SYMBOL}_dataset.zip"
    datasets download gene symbol $GENE_SYMBOL --include gene --taxon "$OUTGROUP" --filename "${GENE_SYMBOL}_${OUTGROUP}_dataset.zip"

    unzip -d $OUTS/orthologs "${GENE_SYMBOL}_dataset.zip"
    unzip -d $OUTS/outgroup "${GENE_SYMBOL}_${OUTGROUP}_dataset.zip"

    # fix the output names to include organism
    sed -i -e '/^>/ s/^>\([^ ]*\).*organism=\([^]]*\).*/>\2-\1/' -e 's/ /_/' $OUTS/outgroup/ncbi_dataset/data/gene.fna
    sed -i -e '/^>/ s/^>\([^ ]*\).*organism=\([^]]*\).*/>\2-\1/' -e 's/ /_/' $OUTS/orthologs/ncbi_dataset/data/gene.fna
}

# Concatenate all outputs
function cat_outputs {
    mkdir -p $MSA
    cat $OUTS/*.fa \
        $OUTS/outgroup/ncbi_dataset/data/gene.fna \
        $OUTS/orthologs/ncbi_dataset/data/gene.fna > $MSA/sequences.fasta

    # Also append the reference sequence with no variants...
    samtools faidx $REFERENCE $REGION >> $MSA/sequences.fasta
}

function do_alignment {
    # run alignment
    mafft --thread $THREADS $MSA/sequences.fasta > $MSA/aligned.fasta
}

function do_tree {
    # Run tree generation

    # Get id of first seq in outgroup fasta. Had to convert : to _ which iqtree apparently does
    OUTGROUP_FASTA=$(head -n1 $OUTS/outgroup/ncbi_dataset/data/gene.fna | cut -d' ' -f1 | cut -c 2- | sed 's/:/_/g')
    # 1000x bootstrap, automatic model selection
    iqtree2 -s $MSA/aligned.fasta -o $OUTGROUP_FASTA -m MFP+MERGE -bb 1000 -nt $THREADS -redo
}


case $1 in
"" | setup) # Default (no params), run all
    setup
    ;&
loop_bams)
    loop_bams
    ;&
download_ncbi)
    download_ncbi
    ;&
cat_outputs)
    cat_outputs
    ;&
do_alignment)
    do_alignment
    ;&
do_tree)
    do_tree
    ;;
esac
