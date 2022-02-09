// 
// Get and parse reference genome files
// 

/*
========================================================================================
    IMPORT LOCAL or NF-CORE MODULES/SUBWORKFLOWS
========================================================================================
*/
include { GUNZIP as GUNZIP_FASTA }      from '../../modules/nf-core/modules/gunzip/main'
include { GUNZIP as GUNZIP_MATURE }     from '../../modules/nf-core/modules/gunzip/main'
include { GUNZIP as GUNZIP_HAIRPIN }    from '../../modules/nf-core/modules/gunzip/main'
include { PREPARE_GENOME; INDICES; PREPARE_MIRBASE_TARGET; PREPARE_MIRBASE_RELATED }  from '../../modules/local/prepare_references/main'

/*
========================================================================================
    RUN SUBWORKFLOW
========================================================================================
*/
workflow PREPARE_REFERENCES {

    main:
    ch_versions = Channel.empty()

    // Uncompress reference genome and miRBase files
    if ( params.fasta.endsWith('.gz') ) {
        ch_genome = GUNZIP_FASTA ( [ [:], params.fasta ] ).gunzip.map { it[1] }   
    } else {
        ch_genome = file( params.fasta )
    }
    if ( params.mature.endsWith('.gz') ) {
        ch_mature = GUNZIP_MATURE ( [ [:], params.mature ] ).gunzip.map { it[1] }
    } else {
        ch_mature = file( params.mature )
    }
    if ( params.hairpin.endsWith('.gz') ) {
        ch_hairpin = GUNZIP_HAIRPIN ( [ [:], params.hairpin ] ).gunzip.map { it[1] }
    } else {
        ch_hairpin = file(params.hairpin)
    }

    // Parsing reference genome
    PREPARE_GENOME( ch_genome )
    ch_genome_edited  = PREPARE_GENOME.out.edited
    ch_genome_nowhite = PREPARE_GENOME.out.nowhite
    
    // Get indices if required
    if ( params.bw_indices ) {
        ch_genome_indices = Channel.fromPath( params.bw_indices )
    } else {
        INDICES ( ch_genome_edited )
            ch_genome_indices = INDICES.out.indices
    }

    // Parsing  mirbase files (mature & hairpin)
    ch_target_sp = Channel.from( params.target_sp )
    PREPARE_MIRBASE_TARGET (
        ch_mature,
        ch_hairpin,
        ch_target_sp
        )
    ch_mature_out   = PREPARE_MIRBASE_TARGET.out.mature
    ch_hairpin_out  = PREPARE_MIRBASE_TARGET.out.hairpin

    // parsing related mirbase species
    if ( params.related_sp ){

        ch_related_sp = Channel.from( params.related_sp )
        PREPARE_MIRBASE_RELATED(
            ch_mature,
            ch_related_sp
            )
        ch_related_out = PREPARE_MIRBASE_RELATED.out.related
    
    } else {
        ch_related_out = Channel.from( 'none' )
    }

    // combine versions
    ch_versions = ch_versions.mix( PREPARE_GENOME.out.versions ) 
    ch_versions = ch_versions.mix( PREPARE_MIRBASE_TARGET.out.versions )

    emit:
    genome          = ch_genome_edited
    genome_nowhite  = ch_genome_nowhite
    indices         = ch_genome_indices
    mature          = ch_mature_out
    hairpin         = ch_hairpin_out
    related         = ch_related_out
    versions        = ch_versions 
}