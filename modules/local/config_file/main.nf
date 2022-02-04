process CONFIG_FILE {
    label 'process_low'
    conda (params.enable_conda ? "conda-forge::r-base=4.1.2 conda-forge::r-dplyr=1.0.7" : null)

    input:
    file input_files

    output:
    path ("*.txt"), emit: file

    script:
    """
    create_configFile.R $input_files
    """
}