rule braker3_bams:
    input:
        proteindb=config["orthodb"],
        bams=BAMS,
        genome=config["genome"]
    params:
        species='{}_{}'.format(config["species"],str(datetime.now().strftime("%m_%d_%Y_%H_%M_%S"))),
        bamstring=",".join(BAMS)
    output:
        "braker/braker.gtf"
    singularity:
        "docker://teambraker/braker3:latest"
    shell:
       """
       export AUGUSTUS_CONFIG_PATH=${{PWD}}/augustus_config
       cp -Rs /opt/Augustus/config/ ${{AUGUSTUS_CONFIG_PATH}}
       braker.pl \
           --prot_seq={input.proteindb} \
           --bam={params.bamstring} \
           --species={params.species} \
           --genome={input.genome} \
           --threads={resources.cpus_per_task}
       """       
