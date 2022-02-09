process GUNZIP_MIRDEEPIN {
    tag "$archive"
    label 'process_low'
    conda (params.enable_conda ? "conda-forge::sed=4.7" : null)

    input:
    file archive

    output:
    path ('*.fq') , emit: unzipped_reads

    script:
    def args = task.ext.args ?: ''
    gunzip = archive.toString() - '.gz'
    """
    gunzip \\
        -f \\
        $args \\
        $archive
    """
}