#!/usr/bin/env nextflow
/*
========================================================================================
    mirnaseq
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
// WORKFLOW: Run main mirnaseq analysis pipeline
//
workflow NF_MIRNASEQ {
    MIRNASEQ ()
}

/*
========================================================================================
    RUN ALL WORKFLOWS
========================================================================================
*/

//
// WORKFLOW: Execute a single named workflow for the pipeline
// See: https://github.com/Daniel-VM/mirnaseq/issues/
//
workflow {
   NF_MIRNASEQ ()
}

/*
========================================================================================
    THE END
========================================================================================
*/
