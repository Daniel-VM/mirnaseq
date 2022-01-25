#!/usr/bin/env nextflow
/*
========================================================================================
    nf-core/mirnaseq
========================================================================================
    Github : https://github.com/Daniel-VM/mirnaseq
----------------------------------------------------------------------------------------
*/

nextflow.enable.dsl = 2

/*
========================================================================================
    VALIDATE & PRINT PARAMETER SUMMARY
========================================================================================
Before executing any process, this pipeline runs initial checks (see lib/) to verify
the user's input consistency (file format, mandatory parameters etc...)
*/

// WorkflowMain.initialise(workflow, params, log) // COMMENT OUT THIS LINE AFTER UPDATING USAGE.MD file

/*
========================================================================================
    NAMED WORKFLOW FOR PIPELINE
========================================================================================
*/

include { MIRNASEQ } from './workflows/mirnaseq'

//
// WORKFLOW: Run main nf-core/mirnaseq analysis pipeline
//
workflow NFCORE_MIRNASEQ {
    MIRNASEQ ()
}

/*
========================================================================================
    RUN ALL WORKFLOWS
========================================================================================
*/

//
// WORKFLOW: Execute a single named workflow for the pipeline
// See: https://github.com/nf-core/rnaseq/issues/619
//
workflow {
    NFCORE_MIRNASEQ ()
}

/*
========================================================================================
    THE END
========================================================================================
*/
