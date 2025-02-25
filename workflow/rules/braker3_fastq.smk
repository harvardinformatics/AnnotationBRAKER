rule braker3_fastq:
    input:
        proteindb=config["orthodb"],
        bams=expand("results/star2ndpass/sorted_{sample}_STAR2ndpassAligned.out.bam",sample=SAMPLES),
        genome=config["genome"]
    params:
        brakersif=config["brakersif"],
        species='{}_{}'.format(config["species"],str(datetime.now().strftime("%m_%d_%Y_%H_%M_%S"))),
        bamstring=",".join(expand("results/star2ndpass/sorted_{sample}_STAR2ndpassAligned.out.bam",sample=SAMPLES))
    output:
        "braker/braker.gtf"
    shell:
       """
       singularity exec --cleanenv {params.brakersif} cp -Rs /opt/Augustus/config/ augustus_config
       singularity exec --no-home \
                 --home /opt/gm_key \
                 --cleanenv \
                 --env AUGUSTUS_CONFIG_PATH=${{PWD}}/augustus_config \
                 {params.brakersif} braker.pl \
                 --prot_seq={input.proteindb} \
                 --bam={params.bamstring} \
                 --species={params.species} \
                 --genome={input.genome} \
                 --threads={resources.cpus_per_task}
       """       
