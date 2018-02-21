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
- p value &lt;= 5x10^-8
File saved in "data/gwas-association-downloaded\_2018-02-21-inflammatory bowel disease.tsv"

A description of the terms can be found <http://www.ebi.ac.uk/gwas/docs/methods>

| DISEASE.TRAIT                                                                                                            |    n|
|:-------------------------------------------------------------------------------------------------------------------------|----:|
| Crohn's disease                                                                                                          |  380|
| Inflammatory bowel disease                                                                                               |  360|
| Ulcerative colitis                                                                                                       |  226|
| Pediatric autoimmune diseases                                                                                            |   28|
| Primary sclerosing cholangitis                                                                                           |   18|
| Inflammatory bowel disease (early onset)                                                                                 |    4|
| Poor prognosis in Crohn's disease                                                                                        |    4|
| Crohn's disease and celiac disease                                                                                       |    2|
| Crohn's disease and psoriasis                                                                                            |    2|
| Response to thiopurine in inflammatory bowel disease (leukopenia)                                                        |    2|
| Ulcerative colitis or Crohn's disease                                                                                    |    2|
| Crohn's disease-related phenotypes                                                                                       |    1|
| Erythema nodosum in inflammatory bowel disease                                                                           |    1|
| Response to thiopurine immunosuppressants in inflammatory bowel disease (pancreatitis) (azathioprine and mercaptopurine) |    1|
