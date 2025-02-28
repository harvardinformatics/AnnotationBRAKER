rule braker3_bams:
    input:
        proteindb=config["orthodb"],
        #bams=expand("{directory}{bam}",directory=config["bamdir"],bam=BAMS),
        bams=BAMS,
        genome=config["genome"]
    params:
        brakersif=config["brakersif"],
        species='{}_{}'.format(config["species"],str(datetime.now().strftime("%m_%d_%Y_%H_%M_%S"))),
        #bamstring=",".join(expand("{directory}{bam}",directory=config["bamdir"],bam=BAMS))
        bamstring=",".join(BAMS)
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
                 --species={params.species}_eval \
                 --genome={input.genome} \
                 --threads={resources.cpus_per_task}
       """       
