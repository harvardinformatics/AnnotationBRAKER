# AnnotationBRAKER
This repository consists of a Snakemake workflow to produce an annotation of protein-coding genes in a genome with [BRAKER](https://github.com/Gaius-Augustus/BRAKER). BRAKER3 is the latest code release and the paper describing how it works can be found [here](https://genome.cshlp.org/content/early/2024/05/28/gr.278090.123.abstract). BRAKER is a method for genome annotation that uses extrinsic evidence to guide optimized model parameterization andcoding sequence feature prediction on a genome sequence with Hidden Markov Model (HMM)-based tools, primarily [AUGUSTUS](https://academic.oup.com/bioinformatics/article/24/5/637/202844?login=false),and, to a lesser extent, [GeneMark](https://genome.cshlp.org/content/34/5/757.long). While BRAKER has a large number of command line options for customizing genome annotation, there are three main ways to predict genes with BRAKER:


* Only using RNA-seq evidence, previously known as [BRAKER1](https://academic.oup.com/bioinformatics/article/32/5/767/1744611)
* Only using protein evidence, previously known as [BRAKER2]([https://academic.oup.com/nargab/article/3/1/lqaa108/6066535)
* Using both RNA-seq and protein evidence, aka BRAKER3.

All three implementations are executed from the same code base.

