process CONFIG_FILE {
    label 'process_low'
    conda (params.enable_conda ? "conda-forge::r-base=4.1.2 conda-forge::r-dplyr=1.0.7 conda-forge::r-stringr=1.4.0" : null)

    input:
    file input_files

    output:
    path ("*.txt")          , emit: file
    path ("*.md")           , emit: proj_dir
    path ("versions.yml")   , emit: versions

    script:
    """
    echo \$PWD > configFile_wd.md
    create_configFile.R $input_files

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        R-base: \$( R --version | awk 'NR==1{print \$3}' )
    END_VERSIONS
    """
}