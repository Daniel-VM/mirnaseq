//
// microRNA analysis with miRDeep2
//

/*
========================================================================================
    IMPORT LOCAL MODULES
========================================================================================
*/
include { CONFIG_FILE               } from '../../modules/local/config_file/main'
include { MAPPER                    } from '../../modules/local/mapper/main'
include { MIRDEEP2; NOVEL_MIRNAS    } from '../../modules/local/mirdeep2/main'
include { QUANTIFY_THEMALL          } from '../../modules/local/quantify_themall/main'

/*
========================================================================================
    IMPORT NF-CORE MODULES
========================================================================================
*/
include { GUNZIP    } from '../../modules/nf-core/gunzip/main'

/*
========================================================================================
    RUN MAIN SUBWORKFLOW
========================================================================================
*/
workflow MIRDEEP {
    take:
    trim_reads
    ch_genome_indices
    ch_genome_nowhite
    ch_mirbase_mature
    ch_mirbase_related
    ch_mirbase_hairpin

    main:
    ch_versions = Channel.empty()

    //
    // MODULE: PREPARE READS FOR MINRASEQ ANALYSIS
    //
    GUNZIP ( trim_reads )
    ch_mirdeep_input = GUNZIP.out.gunzip

    // MODULE: CONFIG FILE - build a miRDeep2 configuration file
    CONFIG_FILE ( 
        ch_mirdeep_input.collect{it[1]}
        )
    reads_list  = CONFIG_FILE.out.file
    ch_versions = ch_versions.mix( CONFIG_FILE.out.versions )

    // MODULE: MAPPER - maps reads against reference genome
    MAPPER ( 
        reads_list,
        ch_genome_indices.collect()
        )
    ch_mapper_collapsed = MAPPER.out.collapsed_reads
    ch_mapper_arf       = MAPPER.out.reads_vs_genome
    ch_mapperStats      = MAPPER.out.stats

    // MODULE: miRNAseq analysis with MIRDEEP2
    MIRDEEP2 (
        ch_mapper_collapsed,
        ch_genome_nowhite,
        ch_mapper_arf,
        ch_mirbase_mature,
        ch_mirbase_related,
        ch_mirbase_hairpin       
    )
    ch_versions = ch_versions.mix( MIRDEEP2.out.versions )

    // MODULE: Novel microRNAs processing
    NOVEL_MIRNAS ( 
        MIRDEEP2.out.toNovelproc,
        ch_mirbase_mature,
        ch_mirbase_hairpin
    )
    ch_mature_plusDenovo    = NOVEL_MIRNAS.out.matureRef_plusDenovo
    ch_hairpin_plusDenovo   = NOVEL_MIRNAS.out.hairpinRef_plusDenovo
    ch_versions             = ch_versions.mix( NOVEL_MIRNAS.out.versions )

    // MODULE: Quantification of known and novel microRNA
    QUANTIFY_THEMALL (
        ch_mature_plusDenovo,
        ch_hairpin_plusDenovo,
        ch_mapper_collapsed
    )
    ch_expression_matrix    = QUANTIFY_THEMALL.out.mirnas_expMat
    ch_versions             = ch_versions.mix( QUANTIFY_THEMALL.out.versions )

    emit:
    versions            = ch_versions
    samples             = reads_list
    mapper_stats        = ch_mapperStats
}