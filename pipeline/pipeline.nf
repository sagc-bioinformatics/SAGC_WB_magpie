
process FASTP {

    publishDir "${params.outdir}/fastp", pattern: "*.html"
    
    //container 'https://depot.galaxyproject.org/singularity/fastp:0.23.4--h5f740d0_0'
    
    cpus 4

    input:
    tuple val(id), path(reads)

    output:
    tuple val(id), path('*.json'), emit: json
    tuple val(id), path('*.html'), emit: html
    
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


workflow {

    channel.fromFilePairs ( params.samples )
        | FASTP  
}
