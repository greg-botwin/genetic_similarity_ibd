library(foreach)
library(doMC)
library(readr)
library(tidyverse)

phenos <- read_tsv("data/UKBB GWAS Manifest 20170915 - dbox_linklist.20170915.tsv")
colnames(phenos) <- make.names(colnames(phenos))
phenos <- phenos %>%
  filter(Phenotype.code != "N/A")

phenos <- phenos[1:2,]

myfunction <- function(phenotype_code, description, file_name, wget_args){
  # download individual gwas result for a specific phenotype
  command <- "wget"
  args <- wget_args
  system2(command, args = args, stdout = NULL, stderr = FALSE)
  
  # read in gwas ~1gb file
  x <- read_tsv(file_name, col_names = TRUE, col_types = list(
    variant = col_character(),
    rsid = col_character(),
    nCompleteSamples = col_integer(),
    AC = col_double(),
    ytx = col_double(),
    beta = col_double(),
    se = col_double(),
    tstat = col_double(),
    pval = col_double()
  ))
  
  # remove raw file
  file.remove(file_name)
  
  x <- x%>%
    filter(pval <= 0.00000005) %>%
    mutate(phenotype_code = phenotype_code) %>%
    mutate(description = description)
  
  return(x)
}

registerDoMC(2) #change the 2 to your number of CPU cores   

datalist <- foreach(i=seq_along(1:nrow(phenos))) %dopar% {  
  
  df <- phenos[i,]
  x <- myfunction(phenotype_code = df$Phenotype.code, 
                  description = df$Description, file_name=df$File,
                  wget_args= df$wget.command) 
  
}

# for(i in seq_along(1:nrow(phenos))){
#   df <- phenos[i,]
#   x <- myfunction(phenotype_code = df$Phenotype.code, 
#                   description = df$Description, file_name=df$File,
#                   wget_args= df$wget.command)
#   datalist[[i]] <- x
# }

sig_assoc <- bind_rows(datalist)
saveRDS(sig_assoc, "data/sig_assoc.RDS")


