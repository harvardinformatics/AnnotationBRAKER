localrules: braker_mover

rule braker_mover:
    input:
        "braker/braker.gtf"
    output:
        "results/braker3/braker/braker.gtf"
    threads: 1
    shell:
        """
        mkdir -p results/braker3
        mv augustus_config results/braker3
        mv braker results/braker3
        """

