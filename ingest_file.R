library(readr)
library(stringr)
library(sqldf)
library(tidyverse)

pheno_summary <- read_tsv("data/phenosummary_final_11898_18597.tsv")
variants <- read_tsv("data/variants.tsv")
sig_assoc <- readRDS(file = "data/sig_assoc.RDS")

# there are two phenotypes with the same description "Treatment/medication code: vitamin c product
x <- sig_assoc %>%
  group_by(phenotype_code, description) %>%
  summarise(n = n())
x$description[duplicated(x$description)]

# mutate description so unique
sig_assoc <- sig_assoc %>%
  mutate(description = if_else(description == "Treatment/medication code: vitamin c product",
                               paste(description, phenotype_code, sep = " "), description))
pheno_summary <- pheno_summary %>%
  mutate(Field = if_else(Field == "Treatment/medication code: vitamin c product",
                         paste(Field, Field.code, sep = " "), Field))

# phenotypes that are quantitiative do not have case control numbers
# phenotypes that are case control by icd code diagnoses, the field code != phenotype code
# the phenotype code = the icd code number 
pheno_summary <- pheno_summary %>%
  mutate(Field.code = if_else(str_detect(Field, "Diagnoses - main ICD10:"), gsub("^.*_", "", Field.code), Field.code))

# 1) Identify the sample size of the smaller of the two groups in the case/control
#phenotype
# 2) Determine the allele frequency where we would expect at least 25 minor alleles
# in the smaller group (e.g. minor allele frequency (MAF) cutoff = 25 (2*samplesize)
# 3) Remove SNPs below this allele frequency cutoff

pheno_summary <- pheno_summary %>%
  mutate(small_sample_n = if_else(is.na(N.cases), N.cases,
                                  if_else(sign(N.cases - N.controls) == 1, N.controls, N.cases))) %>%
  mutate(rec_maf_cut = 25 / (2*small_sample_n))

sig_assoc_pheno <- left_join(sig_assoc, pheno_summary, by = c("phenotype_code" = "Field.code"))

sig_assoc_pheno_qc <- left_join(sig_assoc_pheno, variants, by = "variant")        

sig_assoc_pheno_qc <- sig_assoc_pheno_qc %>%
  filter(is.na(rec_maf_cut) | AF > rec_maf_cut) %>%
  separate(variant, into = c('CHR', 'BP', 'REF', 'ALT'), ':') %>%
  mutate(BP = as.integer(BP))

## number of statistical sig snps per phenotype
View(sig_assoc_pheno_qc %>%
       group_by(phenotype_code, description) %>%
       summarise(n = n()) %>%
       arrange(desc(n)))

## For two diseases, A and B are associated with m mutations and n mutations, 
# respectively. The chance of one mutation related with disease A in all 
# mutations existed in the database is m/N, where N is the total number of 
# mutations in the HGMD. Thus, the expected number of mutations shared by both 
# A and B is m × n/N. We excluded pairs of diseases where one disease was a 
# descendant of the other."

ibd_gwas_catalog <- read_tsv("data/gwas-association-downloaded_2018-02-21-inflammatory bowel disease.tsv") 
colnames(ibd_gwas_catalog) <- make.names(colnames(ibd_gwas_catalog))

# 24 ibd snps not in all variants, one contains multiple snps
# 572 unique snps associated with ibd in variants
table(unique(ibd_gwas_catalog$SNPS) %in% variants$rsid)

# 358-24 ibd snps not statistically sifnificant in any of the associations
table(unique(ibd_gwas_catalog$SNPS) %in% sig_assoc_pheno_qc$rsid.y)

# 238 IBD snps in statisitically significant db
ibd_gwas_catalog %>%
  filter(SNPS %in% sig_assoc_pheno_qc$rsid.y) %>%
  distinct(SNPS) %>%
  nrow()

m <- ibd_gwas_catalog %>%
  filter(SNPS %in% variants$rsid) %>%
  distinct(SNPS) %>%
  unlist()

sig_assoc_pheno_qc %>%
  group_by(description, nCompleteSamples, N.cases, N.controls) %>%
  summarise(n_uk_snps = length(unique(rsid.y)),
            ibd_snp_overlap = sum(unique(rsid.y) %in% m),
            expected_number_overlap = 572 * (n_uk_snps/10886886),
            ratio_overlap_expected = ibd_snp_overlap/expected_number_overlap) %>%
  write_csv(path = "data/sig_assoc_pheno_qc_ibd_verlap.csv")

ibd_self_report_uk_snps <- sig_assoc_pheno_qc %>%
  filter(phenotype_code == "20002_1462") %>%
  write_csv(path = "data/ibd_self_report_uk_bb_snps.csv")

## break up genome into haplotype using doi: 10.1093/bioinformatics/btv546 method
# using european blocks 1703 blocks
haplotype_blocks <- read_tsv(file = "data/fourier_ls-all.bed") %>%
  mutate(block_num = row_number()) %>%
  mutate(chr = substr(chr, 4,5))

# number of blocks per chr
table(haplotype_blocks$chr)
nrow(haplotype_blocks)

# assign ibd gwas catalog snps into haplotype group
ibd_catalog_blocks <- tbl_df(sqldf("
                                   SELECT *
                                   FROM ibd_gwas_catalog d1 LEFT JOIN haplotype_blocks d2
                                   ON d1.CHR_ID = d2.chr
                                   AND d1.CHR_POS >= d2.start and d1.CHR_POS < d2.stop
                                   "))

# number of blocs for ibd snps = 239
View(ibd_catalog_blocks %>%
       group_by(chr, block_num, start, stop) %>%
       summarise(n = n()) %>%
       arrange(desc(n)))

# add haplotype group to uk bb stat sig snps
sig_assoc_pheno_qc_blocks <- sqldf("
                                   SELECT *
                                   FROM sig_assoc_pheno_qc d1 LEFT JOIN haplotype_blocks d2
                                   ON d1.CHR = d2.chr AND d1.BP >= d2.start AND d1.BP < d2.stop
                                   ")

sig_assoc_pheno_qc_blocks %>%
  group_by(description, nCompleteSamples, N.cases, N.controls) %>%
  summarise(n_uk_snps = length(unique(rsid.y)),
            ibd_snp_overlap = sum(unique(rsid.y) %in% m),
            expected_snp_number_overlap = 572 * (n_uk_snps/10886886),
            ratio_snp_overlap_expected = ibd_snp_overlap/expected_snp_number_overlap,
            n_uk_blocks = length(unique(block_num)),
            ibd_block_overlap = sum(unique(block_num) %in% unique(ibd_catalog_blocks$block_num)),
            per_block_overlap = ibd_block_overlap/n_uk_blocks,
            ratio_uk_snps_uk_blocs = n_uk_snps/n_uk_blocks) %>%
  write_csv(path = "data/sig_assoc_pheno_qc_blocks.csv")
