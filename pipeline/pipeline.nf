
process FASTP {

    publishDir "${params.outdir}/fastp", pattern: "*.html"
    
    container 'https://depot.galaxyproject.org/singularity/fastp:0.23.4--h5f740d0_0'
    
    cpus 16

    input:
    tuple val(id), path(reads)

    output:
    tuple val(id), path('*.json'), emit: json
    tuple val(id), path('*.html'), emit: html
    tuple val(id), path('*.fastq.gz'), emit: fastq
    
    """
    # Run quality checks and trimming
    fastp \
        -w $task.cpus \
        --detect_adapter_for_pe \
        --in1 ${reads[0]} \
        --in2 ${reads[1]} \
        --out1 ${id}_R1_001_trimmed.fastq.gz \
        --out2 ${id}_R2_001_trimmed.fastq.gz \
        --json ${id}.fastp.json \
        --html ${id}.fastp.html
    """
}

process BWA_INDEX {

    publishDir "${params.outdir}/reference"

    container 'https://depot.galaxyproject.org/singularity/bwa:0.7.18--he4a0461_0'

    input:
    path fasta

    output:
    path("bwa"), emit: index

    """
    mkdir bwa
    bwa index \
        -p bwa/${fasta.baseName} \
        $fasta
    """
        
}

process BWA_MEM {

    container 'https://depot.galaxyproject.org/singularity/mulled-v2-fe8faa35dbf6dc65a0f7f5d4ea12e31a79f73e40:1bd8542a8a0b42e0981337910954371d0230828e-0'
    
    cpus 16

    input:
    tuple val(id), path(reads)
    path fasta
    path index

    output:
    tuple val(id), path("*.bam"), emit: bam

    """
    bwa mem \
        -t $task.cpus \
        $index/${fasta.baseName} \
        $reads | samtools sort --threads $task.cpus -o ${id}.bam -
    """
}

process SAMTOOLS_INDEX {

    container 'https://depot.galaxyproject.org/singularity/samtools:1.21--h50ea8bc_0'
    
    publishDir "${params.outdir}/indexed_bam"
    
    cpus 4

    input:
    tuple val(id), path(bam)

    output:
    tuple val(id), path(bam), path("*.bai"), emit: indexed

    """
    samtools index \\
        --bai \\
        -@ ${task.cpus-1} \\
        $bam
    """
}

process SAMTOOLS_STATS {

    container 'https://depot.galaxyproject.org/singularity/samtools:1.21--h50ea8bc_0'

    publishDir "${params.outdir}/samtools_stats", pattern: "*.stats"
    
    cpus 4

    input:
    tuple val(id), path(bam), path(index)
    path fasta
    path index

    output:
    tuple val(id), path("*.stats"), emit: stats

    """
    samtools \\
        stats \\
        -@ ${task.cpus-1} \\
        --reference ${fasta} \\
        ${bam} \\
        > ${id}.stats
    """
}

process SAMTOOLS_COVERAGE {

    container 'https://depot.galaxyproject.org/singularity/samtools:1.21--h50ea8bc_0'

    publishDir "${params.outdir}/samtools_stats", pattern: "*.coverage"

    input:
    tuple val(id), path(bam)

    output:
    tuple val(id), path("*.coverage"), emit: coverage

    """
    samtools \\
        coverage \\
        ${bam} \\
        > ${id}.coverage
    """
}

process BCFTOOLS_CALL {

    container 'https://depot.galaxyproject.org/singularity/bcftools:1.20--h8b25389_0'

    publishDir "${params.outdir}/bcftools"

    input:
    tuple val(id), path(bam)
    path fasta

    output:
    tuple val(id), path("*.bcf"), emit: bcf

    """
    bcftools mpileup -Ou \\
        -f $fasta \\
        ${bam} \\
        | bcftools call -mv -Ob -o ${id}.bcf
    """
}

process MULTIQC {

    container 'https://depot.galaxyproject.org/singularity/multiqc:1.27--pyhdfd78af_0'

    publishDir "${params.outdir}/multiQC", pattern: "*.html"

    input:
    path files

    output:
    path '*.html'

    """
    multiqc -n multiqc_report.html ${files}
    """
}

workflow {

    /// Start with quality filtering and adapter trimming of fastq files
    channel.fromFilePairs ( params.samples )
        | FASTP  


    /// Build the index for our reference 
    reference = file(params.genome, checkIfExists: true)
    BWA_INDEX ( reference )

    /// Map trimmed files to the reference
    BWA_MEM ( FASTP.out.fastq, reference, BWA_INDEX.out.index )
    
    /// Do variant calling on bam files
    BCFTOOLS_CALL ( BWA_MEM.out.bam, reference )

    /// Index bam files
    SAMTOOLS_INDEX ( BWA_MEM.out.bam )

    /// Collect stats on indexed bam files
    SAMTOOLS_STATS ( SAMTOOLS_INDEX.out.indexed, reference, BWA_INDEX.out.index )
    
    /// Collect coverage info
    SAMTOOLS_COVERAGE ( BWA_MEM.out.bam )

    /// Combine all output into a single report
    SAMTOOLS_STATS.out.stats
        | mix(FASTP.out.json)
        | mix(SAMTOOLS_COVERAGE.out.coverage)
        | map { it[1] }
        | collect
        | MULTIQC


}
