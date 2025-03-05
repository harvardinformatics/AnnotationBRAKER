#!/bin/bash
#SBATCH -J brakersnake
#SBATCH -n 1                 
#SBATCH -t 72:00:00        
#SBATCH -p sapphire # add partition      
#SBATCH --mem=10000           
#SBATCH -o logs/test.%A.out # need to create logs directory first  
#SBATCH -e logs/test.%A.err  

module purge
module load python
mamba activate snakemake_py311 # need to have created a snakemake conda environment

snakemake --snakefile workflow/Snakefile --use-conda  --profile ~/.config/snakemake/AnnotationBRAKER --workflow-profile ./profiles/slurm



