// 
// Get and parse reference genome files
// 
include { GUNZIP as GUNZIP_FASTA }  from '../../modules/nf-core/modules/gunzip/main'
include { GUNZIP as GUNZIP_MATURE }  from '../../modules/nf-core/modules/gunzip/main'
include { GUNZIP as GUNZIP_HAIRPIN }  from '../../modules/nf-core/modules/gunzip/main'
include { PREPARE_GENOME; PREPARE_MIRBASE_TARGET; PREPARE_MIRBASE_RELATED }  from '../../modules/local/prepare_references/main'

workflow PREPARE_REFERENCES {
//  take: //fix take sp params
    main:
    ch_versions = Channel.empty()

    // uncompress reference genome and mirbase files
    if (params.fasta.endsWith('.gz')) {
        ch_genome = GUNZIP_FASTA ( [ [:], params.fasta ] ).gunzip.map { it[1] }
    } else {
        ch_genome = file(params.fasta)
    }
    if (params.mature.endsWith('.gz')) {
        //reference_mirbaseMature.subscribe {println "Mature miRBase content: ${it.text}"}
        ch_mature = GUNZIP_MATURE ( [ [:], params.mature ] ).gunzip.map { it[1] }
    } else {
        //reference_mirbaseMature.view { println "Mature miRBase content: ${it.text}" }
        ch_mature = file(params.mature)
        //ch_versions = ch_versions.mix(GUNZIP_FASTA.out.versions)
    }
    if (params.hairpin.endsWith('.gz')) {
        ch_hairpin = GUNZIP_HAIRPIN ( [ [:], params.hairpin ] ).gunzip.map { it[1] }
    } else {
        ch_hairpin = file(params.hairpin)
    }

    // parsing reference genome
    PREPARE_GENOME{
        ch_genome
    }
    ch_genome = PREPARE_GENOME.out.edited

    //// parsing reference mirbase (mature & hairpin)
    ch_target_sp = Channel.from(params.target_sp)
    PREPARE_MIRBASE_TARGET (
        ch_mature,
        ch_hairpin,
        ch_target_sp
    )
    ch_mature_out = PREPARE_MIRBASE_TARGET.out.mature
    ch_hairpin_out = PREPARE_MIRBASE_TARGET.out.hairpin

    //// parsing related mirbase species (mature)
    if (params.related_sp){
        ch_related_sp = Channel.from(params.related_sp)
        
        PREPARE_MIRBASE_RELATED(
        ch_mature,
        ch_related_sp
        )
    
        ch_related_out = PREPARE_MIRBASE_RELATED.out.related
    
    } else {
        ch_related_out = Channel.from('none')
    }



    emit:
    fasta = ch_genome
    mature_out = ch_mature
    hairpin = ch_hairpin_out
    related = ch_related_out
}