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
