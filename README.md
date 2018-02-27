README
================
Gregory J. Botwin
2/21/2018

Project Goals
-------------

I want to study phenotypes that are genetically similar to IBD using the UK Biobank Phentoype Data produced by the Neale Lab <http://www.nealelab.is/blog/2017/7/19/rapid-gwas-of-thousands-of-phenotypes-for-337000-samples-in-the-uk-biobank>

Tasks
-----

### Get list of all IBD associated SNPs

On 2/21/18 I queried the NHGRI-EBI Catalog of published genome-wide association studies for:
- Inflammatory Bowel Disease
- p value &lt;= **5x10^-8** File saved in "data/gwas-association-downloaded\_2018-02-21-inflammatory bowel disease.tsv"

A description of the terms can be found <http://www.ebi.ac.uk/gwas/docs/methods>

| DISEASE.TRAIT                                                                                                            |  n\_snps|
|:-------------------------------------------------------------------------------------------------------------------------|--------:|
| Crohn's disease                                                                                                          |      380|
| Inflammatory bowel disease                                                                                               |      360|
| Ulcerative colitis                                                                                                       |      226|
| Pediatric autoimmune diseases                                                                                            |       28|
| Primary sclerosing cholangitis                                                                                           |       18|
| Inflammatory bowel disease (early onset)                                                                                 |        4|
| Poor prognosis in Crohn's disease                                                                                        |        4|
| Crohn's disease and celiac disease                                                                                       |        2|
| Crohn's disease and psoriasis                                                                                            |        2|
| Response to thiopurine in inflammatory bowel disease (leukopenia)                                                        |        2|
| Ulcerative colitis or Crohn's disease                                                                                    |        2|
| Crohn's disease-related phenotypes                                                                                       |        1|
| Erythema nodosum in inflammatory bowel disease                                                                           |        1|
| Response to thiopurine immunosuppressants in inflammatory bowel disease (pancreatitis) (azathioprine and mercaptopurine) |        1|

Notes on the GWAS
-----------------

### Sample Population

-   **487,409** individuals with phased and imputed genotype data
-   filter for British genetic ancestry
-   filter closely related individuals (or at least one of a related pair of individuals)
-   filter individuals with sex chromosome aneuploidies
-   filter individuals who had withdrawn consent from the UK Biobank study
-   left with **337,199** genetically unqiue individuals with British ancestry

### Number of Variants

-   Affymetrix UK BiLEVE Axiom array on an initial 50,000
-   Affymetrix UK Biobank Axiom array on remaining 450,000
-   **820,967** SNP and indel markers on UK Biobank Axiom Array
-   **92 million** imputed autosomal SNPs were available for analysis.
-   Someone screwed up, half of these SNPs were undergoing re-imputation by the UK Biobank team due to mapping issues, leaving the ~40 autosomal million SNPs imputed from the Haplotype Reference Consortium as eligible for analysis.
-   restricted to SNPs with minor allele frequency (MAF) &gt; 0.1%
-   restricted to SNPs with HWE p-value &gt; 1e-10
-   leaving **10,894,596** million SNPs for analysis

### Association Tests (Neale Lab)

-   least-squares linear model predicting the phenotype with an additive genotype coding (0, 1, or 2 copies of the minor allele) for all phenotypes
-   sex and the first 10 principal components provided as covariates

### Post-Hoc QC

-   Post-Hoc analysis by Neale lab found statistical inflation, elevated lambda GC, in case control analysis with small case size and large control size.
-   this inflation was dominant among the lowest frequency SNPs.
-   Neale lab recommends to determine the allele frequency where we would expect at least 25 minor alleles in the smaller group for each phenotype and to remove SNPs below that threshold

Determine Genetic Similarity
----------------------------

"For two diseases, A and B are associated with m mutations and n mutations, respectively. The chance of one mutation related with disease A in all mutations existed in the database is m/N, where N is the total number of variants in the UKBB. Thus, the expected number of mutations shared by both A and B is m × n/N..." DOI: 10.1002/humu.23358
