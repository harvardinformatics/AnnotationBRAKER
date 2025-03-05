def get_star_sa_index_nbases():
    genome = open(config["genome"],"r")
    genome_length = 0
    for line in genome:
        if line[0] != ">":
            genome_length+=(len(line.strip()))
    saindex = int(min(14,log2(genome_length)/2 - 1))
    return saindex

rule star_index:
    input:
        config["genome"]
    output:
        config["star_index_dir"] + "SA"
    conda:
        "../envs/star.yml"
    threads: 24
    params:
        nbases=get_star_sa_index_nbases(),
        outdir=config["star_index_dir"]
    shell:
        """
        STAR --runMode genomeGenerate --genomeSAindexNbases {params.nbases} \
        --runThreadN {threads} --genomeDir {params.outdir} \
        --genomeFastaFiles {input}
        """  
    
