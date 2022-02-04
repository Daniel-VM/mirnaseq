#!/usr/bin/env Rscript

# Load or install if needed 
if (!require("dplyr")){
  install.packages("dplyr", dependencies=TRUE, repos='http://cloud.r-project.org/')
  library("dplyr")
}

# Command line arguments
args <- commandArgs(trailingOnly = TRUE)
input <- as.character(args[1:length(args)]) %>% basename

# Generate three-letter code to each sample file
id_generator <- function(input=NULL){
  
  magord <- length(input) %>% nchar()
  
  if ( magord <= 3 ) {
    
    id_out <-  seq(input) %>% sprintf("%03d", .)
     
  } else if ( magord > 3 ) {
    # combine digit and strings
    stop("This version allows up to 999 samples. Use a preconfigured input file instead:\n  --inputList path_to/samples_inputList.txt")
  }
  return(id_out)
}

df <- data.frame(sample = input) %>%
  mutate(id = id_generator(sample))
write.table(df, file = "input_configFile.txt", quote = FALSE, col.names = FALSE, row.names = FALSE)
