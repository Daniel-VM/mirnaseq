process MAPPER {
    label 'process_low'
    conda (params.enable_conda ? "bioconda::mirdeep2=2.0.1.2" : null)

    input:
    file input_list
    file genome_indices

    output:
    path ('*.fa')   , emit: collapsed_reads
    path ('*.arf')  , emit: reads_vs_genome

    script:
    index_baseName = genome_indices.toString().tokenize(' ')[0].tokenize('.')[0]

    """
    mapper.pl $input_list \\
    -d -e -h -j -m -v \\
	-l 17 \\
	-o ${task.cpus} \\
	-s reads_collapsed.fa \\
	-p $index_baseName \\
	-t reads_collapsed_vs_genome.arf
    """
}