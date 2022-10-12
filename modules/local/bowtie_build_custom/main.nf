process BOWTIE_BUILD_CUSTOM {
    tag "$fasta"
    label 'process_high_memory'

    conda (params.enable_conda ? 'bioconda::bowtie=1.3.1' : null)
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/bowtie:1.3.1--py39hd400a0c_2' :
        'quay.io/biocontainers/bowtie:1.3.1--py39hd400a0c_2' }"

    input:
    path fasta

    output:
    path '*.ebwt'       , emit: index
    path "versions.yml" , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    """
    bowtie-build --threads $task.cpus $fasta genome
    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        bowtie: \$(echo \$(bowtie --version 2>&1) | sed 's/^.*bowtie-align-s version //; s/ .*\$//')
    END_VERSIONS
    """
}
