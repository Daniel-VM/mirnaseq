process FASTQC {

    input:
    file reads

    output:
    path("*.txt"), emit: txt

    script:
    prefix = reads.toString() - '.fastq.gz'
    """
    echo "processing $reads" > ${prefix}.txt   
    """
}

 