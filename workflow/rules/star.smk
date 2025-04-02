def input_function_r1(wildcards):
    return sampleinfo.loc[sampleinfo["sampleid"] ==wildcards.sample,"R1"].values[0] 

def input_function_r2(wildcards):
    return sampleinfo.loc[sampleinfo["sampleid"] ==wildcards.sample,"R2"].values[0]

rule star_1stpass:
    input:
        r1 = input_function_r1,
        r2 = input_function_r2,
        index=config["star_index_dir"] + "SA"
    output:
        "results/star1stpass/" + "{sample}" + "_STAR1stpassSJ.out.tab"
    conda:
        "../envs/star.yml"
    threads: 8
    params:
        indexdir = config["star_index_dir"]
    shell:
        """
        rm -rf results/star1stpass/{wildcards.sample}_1stpassSTARtmp
        STAR --runThreadN {resources.cpus_per_task} --genomeDir {params.indexdir} \
        --outFileNamePrefix results/star1stpass/{wildcards.sample}_STAR1stpass \
        --outTmpDir results/star1stpass/{wildcards.sample}_1stpassSTARtmp \
        --readFilesIn <(gunzip -c {input.r1}) <(gunzip -c {input.r2}) 
        """       

rule star_2ndpass:
    input:
        tablelist = expand("results/star1stpass/{sample}_STAR1stpassSJ.out.tab",sample=SAMPLES),
        r1 = input_function_r1,
        r2 = input_function_r2,
        index=config["star_index_dir"] + "SA"
    output:
        "results/star2ndpass/" + "{sample}" + "_STAR2ndpassAligned.out.sam"
    conda:
        "../envs/star.yml"
    threads: 8
    params:
        indexdir = config["star_index_dir"],
        tablestring = ' '.join(expand("results/star1stpass/{sample}_STAR1stpassSJ.out.tab", sample=SAMPLES))
    shell:
        """
        rm -rf results/star2ndpass/{wildcards.sample}_2ndpassSTARtmp
        STAR --runThreadN {threads} \
        --genomeDir {params.indexdir} \
        --outTmpDir results/star2ndpass/{wildcards.sample}_2ndpassSTARtmp \
        --outSAMstrandField intronMotif \
        --sjdbFileChrStartEnd {params.tablestring} \
        --outFileNamePrefix results/star2ndpass/{wildcards.sample}_STAR2ndpass \
        --readFilesIn <(gunzip -c {input.r1}) <(gunzip -c {input.r2})
        """

rule samsort_star:
    input:
        "results/star2ndpass/" + "{sample}" + "_STAR2ndpassAligned.out.sam"
    output:
        "results/star2ndpass/sorted_" + "{sample}" + "_STAR2ndpassAligned.out.bam"
    conda:
        "../envs/samtools.yml"
    threads: 12
    shell:
        """
        mkdir -p results/star2ndpass/tmp
        rm -f results/star2ndpass/tmp/{wildcards.sample}.aln.sorted*bam
        samtools sort -@ {threads} -T results/star2ndpass/tmp/{wildcards.sample}.aln.sorted -O bam -o {output} {input}
        """ 
