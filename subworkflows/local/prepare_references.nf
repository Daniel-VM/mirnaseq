// 
// Get and parse reference genome files
// 
include { GUNZIP as GUNZIP_FASTA }  from '../../modules/nf-core/modules/gunzip/main'
include { PREPARE_GENOME }          from '../../modules/local/prepare_references/main'

workflow PREPARE_REFERENCES {
    take:
    reference_genome
    reference_mirbaseMature
    reference_mirbaseHairpin

    main:
    ch_versions = Channel.empty()

    // uncompress reference genome and mirbase files
    if (reference_genome.endsWith('.gz')) {
        ch_genome = GUNZIP_FASTA ( [ [:], reference_genome  ] ).gunzip.map { it[1] }
    } else {
        ch_genome = file(params.fasta)
    }
    if (reference_mirbaseMature.endsWith('.gz')) {
        ch_mature = GUNZIP_FASTA ( [ [:], reference_mirbaseMature  ] ).gunzip.map { it[1] }
    } else {
        ch_mature = file(params.mature)
        //ch_versions = ch_versions.mix(GUNZIP_FASTA.out.versions)
    }
    if (reference_mirbaseHairpin.endsWith('.gz')) {
        ch_hairpin = GUNZIP_FASTA ( [ [:], reference_mirbaseHairpin  ] ).gunzip.map { it[1] }
    } else {
        ch_hairpin = file(params.hairpin)
    }
    // parsing reference genome
    PREPARE_GENOME{
        ch_genome
    }
    ch_fasta = PREPARE_GENOME.out.edited

    //// parsing reference mirbase (mature & hairpin)
    //PREPARE_MIRBASE (
    //    ch_mature,
    //    ch_hairpin
    //)

    emit:
    fasta = ch_fasta
}