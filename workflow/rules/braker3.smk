get_bam_input(bamdir):
    bamfiles=glob("%s*bam" % bamdir)
    bamstring = ",".join(bamfiles)
    return bamstring

rule braker3_bams:
    input:
        proteindb=config["orthodb"]
        bams=get_bam_input[config["bamdir"]
        genome=config["genome"]
    params:
        brakersif=config["brakersif"]
        species=config["species"]
    output:
        "results/braker/braker.gtf"
    threads: 48
    shell:
       """
       singularity exec --cleanenv {params.brakersif} cp -Rs /opt/Augustus/config/ augustus_config
       singularity exec --no-home \
                 --home /opt/gm_key \
                 --cleanenv \
                 --env AUGUSTUS_CONFIG_PATH=\${{PWD}}augustus_config \
                 {params.brakersif} braker.pl \
                 --prot_seq={input.proteindb} \
                 --bam={input.bams} \
                 --species={myspecies}_eval \
                 --genome={genome} \
                 --threads={threads}
       """       

