# AnnotationBRAKER
This repository consists of a Snakemake workflow to produce an annotation of protein-coding genes in a genome with [BRAKER](https://github.com/Gaius-Augustus/BRAKER). BRAKER3 is the latest code release and the paper describing how it works can be found [here](https://genome.cshlp.org/content/early/2024/05/28/gr.278090.123.abstract). BRAKER is a method for genome annotation that uses extrinsic evidence to guide optimized model parameterization andcoding sequence feature prediction on a genome sequence with Hidden Markov Model (HMM)-based tools, primarily [AUGUSTUS](https://academic.oup.com/bioinformatics/article/24/5/637/202844?login=false),and, to a lesser extent, [GeneMark](https://genome.cshlp.org/content/34/5/757.long). While BRAKER has a large number of command line options for customizing genome annotation, there are three main ways to predict genes with BRAKER:


* Only using RNA-seq evidence, previously known as [BRAKER1](https://academic.oup.com/bioinformatics/article/32/5/767/1744611)
* Only using protein evidence, previously known as [BRAKER2]([https://academic.oup.com/nargab/article/3/1/lqaa108/6066535)
* Using both RNA-seq and protein evidence, aka BRAKER3. BRAKER3 runs separate protein-only and RNA-seq only gene prediction analyses, then merges them by selecting transcripts using a scoring schema with [TSEBRA](https://github.com/Gaius-Augustus/TSEBRA).

All three implementations are executed from the same code base.

## Software requirements
This workflow runs BRAKER from inside a Singularity container. Therefore, you need to do the following:
1. If you haven't done so already, install Snakemake. We recommend doing this into a conda environment, using a MiniForge python distribution:
```bash
mamba create -n snakemake python=3.11
mamba activate snakemake
mamba install snakemake
mamba install bioconda::snakemake-executor-plugin-slurm 
mamba deactivate
``` 
2. Create the BRAKER singularity container
```bash
singularity build braker3.sif docker://teambraker/braker3:latest
``` 

The location of *braker3.sif* must be specified in *config/config.yaml*.

NOTE: when running this workflow, it will have to be done from inside the *snakemake* conda environment so that Snakemake is accessible. This workflow was developed to run on a cluster that uses SLURM as the job scheduler, and we have provided a SLURM job-runner script *braker_snakemake_slurm_runner.sh* , that can be modified for use with other schedulers. 

## Protein evidence
Protein evidence for BRAKER2 and BRAKER3 should be in the form of a fasta file, derived from [OrthoDB](https://www.orthodb.org/), using a taxonomically relevant subset of the complete database. A convenient way to generate such fasta files is using [orthodb-clades](https://github.com/tomasbruna/orthodb-clades), written by the lead developer of BRAKER2. While this Snakemake workflow by default generates a handful of clade-level fasta files, as well as several species-level ones, it is straightforward to edit the underlying code to produce outputs customized to your taxonomic needs. In our experience, this is far easier than attempting to use the OrthoDB API.

## RNA-seq evidence
This workflow requires paired-end RNA-seq reads, and these can be supplied as fastq files or as spliced alignments to the genome in *bam* format. When fastq files are supplied, this workflow aligns the reads with [STAR](https://github.com/alexdobin/STAR), and [Dobin et al., 2013](https://academic.oup.com/bioinformatics/article/29/1/15/272537) in 2-pass mode, and this includes the construction of the STAR mapping index.

At present, this workflow does not allow for the use of long RNA-seq reads such as those generated with Pacific Biosciences or Oxford Nanopore Technologies sequencing instruments. With short reads, we have found that direct assembly of reads into transcripts often leads to higher quality genome annotations than with BRAKER, and we suspect that will be even more the case with long RNA-seq reads, although this needs to be confirmed with additional testing. We strongly suggest that, when you have paired-end RNA-seq data, that you also generate annotations with Stringtie combined with TransDecoder, and compare your outputs from BRAKER with this approach. It can be easily implemented in another of our Snakemake workflows found [here](https://github.com/harvardinformatics/AnnotationRNAseqAssembly).

