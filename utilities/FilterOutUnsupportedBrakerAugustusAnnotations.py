import argparse
fields = ["seqid", "source", "type", "start",
          "end", "score", "strand", "phase", "attributes"]
          
def ParseBrakerGtfAttributes(attributes,cleanlabels=True):
    attribute_dict = {}
    attribute_list = attributes[:-1].replace('"','').split(';')
    for attribute in attribute_list:
        key,value = attribute.split()
        if cleanlabels == True:
            if key in ['transcript_id','gene_id'] and 'file' in value:
                value = value.split('_')[-1]
        attribute_dict[key] =  value
    return attribute_dict
    
def BuiltTscript2GeneDict(brakergtf,fields):
    fopen = open(brakergtf,'r')
    ts2gene = {}
    for line in fopen:
        linedict = dict(zip(fields,line.strip().split('\t')))
        if linedict['type'] == 'CDS':
            attribute_dict = ParseBrakerGtfAttributes(linedict['attributes'],cleanlabels=False)
            ts2gene[attribute_dict['transcript_id']] = attribute_dict['gene_id']
    fopen.close()
    return ts2gene


if __name__=="__main__": 
    parser = argparse.ArgumentParser(description="Filters braker.gtf by retaining only supported annotations, with either any or full support gtfs produced by BRAKER selectSupportedSubsets.py script.")
    parser.add_argument('-supported','--hint-supported-gtf',dest='supported',type=str,help='braker support eval script generated gtf with any support')
    parser.add_argument('-gtf','--braker-gtf',dest='braker',type=str,help='braker.gtf output file')
    parser.add_argument('-o','--output-gtf',dest='output',type=str,help='merge of GeneMark and supported AUGUSTUS annotations')
    parser.add_argument('-blastp','--use-blastp-support',dest='blastp',action='store_true',help='switch indicating whether use blastp evidence to keep annotations')    
    parser.add_argument('-bp-file','--blastp-results-file',dest='blastpfile',type=str,help='name of file with blastp results, outputformat 6')
    opts = parser.parse_args()
   
    if opts.blastp == True:
        ts2gene = BuiltTscript2GeneDict(opts.braker,fields)
        blastp_supported_genes = set()
        blastp_supported_tscripts = set()
        blastp_open = open(opts.blastpfile,'r')
        for line in blastp_open:
            linelist = line.strip().split('\t')
            blastp_supported_tscripts.add(linelist[0])
            blastp_supported_genes.add(ts2gene[linelist[0]]) 




    supported_genes = set()
    supported_tscripts = set()
    supported = open(opts.supported,'r')
    for line in supported:
        if line[0] !='#':
            linedict = dict(zip(fields,line.strip().split('\t')))
            if linedict['type'] in ['intron','start_codon','stop_codon']:
                attribute_dict = ParseBrakerGtfAttributes(linedict['attributes'])
                if attribute_dict['supported'] == 'True':
                    supported_genes.add(attribute_dict['gene_id'])
                    supported_tscripts.add(attribute_dict['transcript_id']) 
                     
    brakerin = open(opts.braker,'r')
    fout = open(opts.output,'w')
    for line in brakerin:
        if line[0] == '#':
            fout.write(line)
        elif line =='\n':
            pass
        elif "GeneMark" in line:
            if opts.blastp == True:
                linedict = dict(zip(fields,line.strip().split('\t')))
                attribute_dict = ParseBrakerGtfAttributes(linedict['attributes'],cleanlabels=False)
                if attribute_dict['transcript_id'] in blastp_supported_tscripts and attribute_dict['gene_id'] in blastp_supported_genes: 
                    fout.write(line)
            else:
                fout.write(line)
        else:
            linedict = dict(zip(fields,line.strip().split('\t')))
            if linedict['type'] == 'gene':
                if linedict['attributes'].split('_')[-1] in supported_genes:
                    fout.write(line)
                elif linedict['attributes'] in blastp_supported_genes:
                    fout.write(line)
            elif linedict['type'] == 'transcript':
                if linedict['attributes'].split('_')[-1] in supported_tscripts:
                    fout.write(line)
                elif linedict['attributes'] in blastp_supported_tscripts:
                    fout.write(line)
            elif linedict['type'] in ['exon','CDS','stop_codon','start_codon','intron']:
                attribute_dict = ParseBrakerGtfAttributes(linedict['attributes'])
                if attribute_dict['gene_id'] in supported_genes and attribute_dict['transcript_id'] in supported_tscripts:
                    fout.write(line)
                else:
                    attribute_dict = ParseBrakerGtfAttributes(linedict['attributes'],cleanlabels=False)
                    if attribute_dict['gene_id'] in blastp_supported_genes and attribute_dict['transcript_id'] in blastp_supported_tscripts:
                        fout.write(line)
            else:
                raise ValueError('%s not in list of valid feature types' % line_dict['type'])

    fout.close() 
