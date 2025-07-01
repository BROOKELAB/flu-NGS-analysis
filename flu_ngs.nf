#!/usr/bin/env nextflow


/*                    
* Set parameter values 
*/                    

// Path to project directory
params.projectPath = "/home/groups/hpcbio_shared/cbrooke_lab/Mireille/test_nf"

// Path to raw reads directory
params.fastqPath = "${params.projectPath}/fastq"

// Path to .csv file with sample metadata
params.metaPath = "${params.projectPath}/sampleinfo.csv"

// Host species ('human' or 'mouse')
params.host = 'human'

//Generate consensus sequence? ('TRUE' or 'FALSE')
params.callConsensus = 'TRUE'

//Generate per-nucleotide depth statistics? ('TRUE' or 'FALSE')
params.callDepth = 'TRUE'

//Perform variant-calling? ('TRUE' or 'FALSE')
params.callVariants = 'TRUE'

// Minimum read quality for variant calling
params.minQual = '20'

// Minimum iSNV frequency for variant calling
params.minFreq = '0.03'

// Biocluster options (memory in gigabytes)
params.queue = 'normal'
params.memory = '15'
params.CPU = '6'

// Paths to bowtie2 indices
params.humanIndex = "/home/groups/hpcbio_shared/cbrooke_lab/reference_sequences/human/human_build"
params.mouseIndex = "/home/groups/hpcbio_shared/cbrooke_lab/reference_sequences/mouse/GRCm39"

params.PB2IndexH1N1 = "/home/groups/hpcbio_shared/cbrooke_lab/reference_sequences/H1N1/H1N1_Wis67_1_PB2"
params.PB1IndexH1N1 = "/home/groups/hpcbio_shared/cbrooke_lab/reference_sequences/H1N1/H1N1_Wis67_2_PB1"
params.PAIndexH1N1 = "/home/groups/hpcbio_shared/cbrooke_lab/reference_sequences/H1N1/H1N1_Wis67_3_PA"
params.HAIndexH1N1 = "/home/groups/hpcbio_shared/cbrooke_lab/reference_sequences/H1N1/H1N1_Wis67_4_HA"
params.NPIndexH1N1 = "/home/groups/hpcbio_shared/cbrooke_lab/reference_sequences/H1N1/H1N1_Wis67_5_NP"
params.NAIndexH1N1 = "/home/groups/hpcbio_shared/cbrooke_lab/reference_sequences/H1N1/H1N1_Wis67_6_NA"
params.MIndexH1N1 = "/home/groups/hpcbio_shared/cbrooke_lab/reference_sequences/H1N1/H1N1_Wis67_7_M"
params.NSIndexH1N1 = "/home/groups/hpcbio_shared/cbrooke_lab/reference_sequences/H1N1/H1N1_Wis67_8_NS"

params.PB2IndexH3N2 = "/home/groups/hpcbio_shared/cbrooke_lab/reference_sequences/H3N2/H3N2_Mas18_1_PB2"
params.PB1IndexH3N2 = "/home/groups/hpcbio_shared/cbrooke_lab/reference_sequences/H3N2/H3N2_Mas18_2_PB1"
params.PAIndexH3N2 = "/home/groups/hpcbio_shared/cbrooke_lab/reference_sequences/H3N2/H3N2_Mas18_3_PA"
params.HAIndexH3N2 = "/home/groups/hpcbio_shared/cbrooke_lab/reference_sequences/H3N2/H3N2_Mas18_4_HA"
params.NPIndexH3N2 = "/home/groups/hpcbio_shared/cbrooke_lab/reference_sequences/H3N2/H3N2_Mas18_5_NP"
params.NAIndexH3N2 = "/home/groups/hpcbio_shared/cbrooke_lab/reference_sequences/H3N2/H3N2_Mas18_6_NA"
params.MIndexH3N2 = "/home/groups/hpcbio_shared/cbrooke_lab/reference_sequences/H3N2/H3N2_Mas18_7_M"
params.NSIndexH3N2 = "/home/groups/hpcbio_shared/cbrooke_lab/reference_sequences/H3N2/H3N2_Mas18_8_NS"

params.PB2IndexIBV = "/home/groups/hpcbio_shared/cbrooke_lab/reference_sequences/IBV/IBV_Tex20_1_PB2"
params.PB1IndexIBV = "/home/groups/hpcbio_shared/cbrooke_lab/reference_sequences/IBV/IBV_Tex20_1_PB1"
params.PAIndexIBV = "/home/groups/hpcbio_shared/cbrooke_lab/reference_sequences/IBV/IBV_Tex20_1_PA"
params.HAIndexIBV = "/home/groups/hpcbio_shared/cbrooke_lab/reference_sequences/IBV/IBV_Tex20_1_HA"
params.NPIndexIBV = "/home/groups/hpcbio_shared/cbrooke_lab/reference_sequences/IBV/IBV_Tex20_1_NP"
params.NAIndexIBV = "/home/groups/hpcbio_shared/cbrooke_lab/reference_sequences/IBV/IBV_Tex20_1_NA"
params.MIndexIBV = "/home/groups/hpcbio_shared/cbrooke_lab/reference_sequences/IBV/IBV_Tex20_1_M"
params.NSIndexIBV = "/home/groups/hpcbio_shared/cbrooke_lab/reference_sequences/IBV/IBV_Tex20_1_NS"

// Module versions
params.fastpMod = 'fastp/0.23.4'
params.cutadaptMod = 'cutadapt/3.7-IGB-gcc-8.2.0-Python-3.7.2'
params.bowtie2Mod = 'Bowtie2/2.5.3-IGB-gcc-8.2.0'
params.samtoolsMod = 'SAMtools/1.17-IGB-gcc-8.2.0'
params.javaMod = 'Java/17.0.6'
params.ivarMod = 'ivar/1.3.1-IGB-gcc-8.2.0'

// Path to picard
params.picardPath = "/home/apps/software/picard/3.4.0-Java-17.0.6/picard.jar"


/*                    
* END of parameters section
*/                    


/*
* Step 1. Trim adapters
*/

process TRIM_ADAPTERS {
    fair true
    module "${params.fastpMod}"
    publishDir "${params.projectPath}/adapter_trimmed", mode: 'copy'
    
    input:
    tuple path(r1), path(r2)
    val sample
    
    output:
    tuple path("${sample}_R1_trimmed.fastq.gz"), path("${sample}_R2_trimmed.fastq.gz")

    script:
    """
    
    fastp -i $r1 -I $r2 -o ${sample}_R1_trimmed.fastq.gz -O ${sample}_R2_trimmed.fastq.gz
    
    """
    
}

/*
* Step 2. Trim 5' MBT-Uni 12 sequences
*/

process CUT_G12 {
    fair true
    executor 'slurm'
    queue params.queue
    memory params.memory
    cpus params.CPU
    module "${params.cutadaptMod}"
    
    input:
    tuple path(r1), path(r2)
    val sample
    
    output:
    tuple path("${sample}_R1_cutadapt_G12.fastq.gz"), path("${sample}_R2_cutadapt_G12.fastq.gz")

    script:
    """
    
    cutadapt -g AGCAAAAGCAGG -G AGCAAAAGCAGG -n 10 -m 15 -o ${sample}_R1_cutadapt_G12.fastq.gz -p ${sample}_R2_cutadapt_G12.fastq.gz $r1 $r2

    """
    
}

/*
* Step 3. Trim 5' MBT-Uni 13 sequences
*/

process CUT_G13 {
    fair true
    executor 'slurm'
    queue params.queue
    memory params.memory
    cpus params.CPU
    module "${params.cutadaptMod}"
    
    input:
    tuple path(r1), path(r2)
    val sample
    
    output:
    tuple path("${sample}_R1_cutadapt_G13.fastq.gz"), path("${sample}_R2_cutadapt_G13.fastq.gz")

    script:
    """
    
    cutadapt -g AGTAGAAACAAGG -G AGTAGAAACAAGG -n 10 -m 15 -o ${sample}_R1_cutadapt_G13.fastq.gz -p ${sample}_R2_cutadapt_G13.fastq.gz $r1 $r2

    """
    
}

/*
* Step 4. Trim 3' MBT-Uni 12 sequences
*/

process CUT_A12 {
    fair true
    executor 'slurm'
    queue params.queue
    memory params.memory
    cpus params.CPU
    module "${params.cutadaptMod}"
    
    input:
    tuple path(r1), path(r2)
    val sample
    
    output:
    tuple path("${sample}_R1_cutadapt_A12.fastq.gz"), path("${sample}_R2_cutadapt_A12.fastq.gz")

    script:
    """
    
    cutadapt -a CCTGCTTTTGCT -A CCTGCTTTTGCT -n 10 -m 15 -o ${sample}_R1_cutadapt_A12.fastq.gz -p ${sample}_R2_cutadapt_A12.fastq.gz $r1 $r2

    """
    
}

/*
* Step 5. Trim 3' MBT-Uni 13 sequences
*/

process CUT_A13 {
    fair true
    executor 'slurm'
    queue params.queue
    memory params.memory
    cpus params.CPU
    module "${params.cutadaptMod}"
    publishDir "${params.projectPath}/primer_trimmed", mode: 'copy'
    
    input:
    tuple path(r1), path(r2)
    val sample
    
    output:
    tuple path("${sample}_R1_cutadapt_A13.fastq.gz"), path("${sample}_R2_cutadapt_A13.fastq.gz")

    script:
    """
    
    cutadapt -a CCTTGTTTCTACT -A CCTTGTTTCTACT -n 10 -m 15 -o ${sample}_R1_cutadapt_A13.fastq.gz -p ${sample}_R2_cutadapt_A13.fastq.gz $r1 $r2

    """
    
}

/*
* Step 6. Filter out host-aligned reads
*/

process FILTER_HOST {
    fair true
    executor 'slurm'
    queue params.queue
    memory params.memory
    cpus params.CPU
    module "${params.bowtie2Mod}"
    publishDir "${params.projectPath}/filtered", mode: 'copy'
    
    input:
    tuple path(r1), path(r2)
    val sample
    
    output:
    path("${sample}_host.sam"), emit: host_sam
    tuple path("${sample}_host.1.fastq"), path("${sample}_host.2.fastq"), emit: host_fastq
    tuple path("${sample}_filtered.1.fastq"), path("${sample}_filtered.2.fastq"), emit: filtered_fastq

    script:
    """
    if [ "$params.host" == "human" ]; then 
        bowtie2 -x $params.humanIndex -1 $r1 -2 $r2 -S ${sample}_host.sam --al-conc ${sample}_host.fastq --un-conc ${sample}_filtered.fastq 
    fi
    
    if [ "$params.host" == "mouse" ]; then 
        bowtie2 -x $params.mouseIndex -1 $r1 -2 $r2 -S ${sample}_host.sam --al-conc ${sample}_host.fastq --un-conc ${sample}_filtered.fastq 
    fi

    """
    
}

/*
* Step 7. Align to viral reference sequences
*/

process ALIGN_VIRUS {
    fair true
    executor 'slurm'
    queue params.queue
    memory params.memory
    cpus params.CPU
    module "${params.bowtie2Mod}"
    
    input:
    tuple path(r1), path(r2)
    val sample
    val subtype
    
    output:
    tuple path("${sample}_PB2.sam"), path("${sample}_PB1.sam"), path("${sample}_PA.sam"), path("${sample}_HA.sam"), path("${sample}_NP.sam"), path("${sample}_NA.sam"), path("${sample}_M.sam"), path("${sample}_NS.sam")
    
    script:
    """
    
    if [ "$subtype" == "H1N1" ]; then 
        bowtie2 -x $params.PB2IndexH1N1 -1 $r1 -2 $r2 -S ${sample}_PB2.sam
        bowtie2 -x $params.PB1IndexH1N1 -1 $r1 -2 $r2 -S ${sample}_PB1.sam
        bowtie2 -x $params.PAIndexH1N1 -1 $r1 -2 $r2 -S ${sample}_PA.sam
        bowtie2 -x $params.HAIndexH1N1 -1 $r1 -2 $r2 -S ${sample}_HA.sam
        bowtie2 -x $params.NPIndexH1N1 -1 $r1 -2 $r2 -S ${sample}_NP.sam
        bowtie2 -x $params.NAIndexH1N1 -1 $r1 -2 $r2 -S ${sample}_NA.sam
        bowtie2 -x $params.MIndexH1N1 -1 $r1 -2 $r2 -S ${sample}_M.sam
        bowtie2 -x $params.NSIndexH1N1 -1 $r1 -2 $r2 -S ${sample}_NS.sam 
    fi
    
    if [ "$subtype" == "H3N2" ]; then 
        bowtie2 -x $params.PB2IndexH3N2 -1 $r1 -2 $r2 -S ${sample}_PB2.sam
        bowtie2 -x $params.PB1IndexH3N2 -1 $r1 -2 $r2 -S ${sample}_PB1.sam
        bowtie2 -x $params.PAIndexH3N2 -1 $r1 -2 $r2 -S ${sample}_PA.sam
        bowtie2 -x $params.HAIndexH3N2 -1 $r1 -2 $r2 -S ${sample}_HA.sam
        bowtie2 -x $params.NPIndexH3N2 -1 $r1 -2 $r2 -S ${sample}_NP.sam
        bowtie2 -x $params.NAIndexH3N2 -1 $r1 -2 $r2 -S ${sample}_NA.sam
        bowtie2 -x $params.MIndexH3N2 -1 $r1 -2 $r2 -S ${sample}_M.sam
        bowtie2 -x $params.NSIndexH3N2 -1 $r1 -2 $r2 -S ${sample}_NS.sam 
    fi
    
    if [ "$subtype" == "IBV" ]; then 
        bowtie2 -x $params.PB2IndexIBV -1 $r1 -2 $r2 -S ${sample}_PB2.sam
        bowtie2 -x $params.PB1IndexIBV -1 $r1 -2 $r2 -S ${sample}_PB1.sam
        bowtie2 -x $params.PAIndexIBV -1 $r1 -2 $r2 -S ${sample}_PA.sam
        bowtie2 -x $params.HAIndexIBV -1 $r1 -2 $r2 -S ${sample}_HA.sam
        bowtie2 -x $params.NPIndexIBV -1 $r1 -2 $r2 -S ${sample}_NP.sam
        bowtie2 -x $params.NAIndexIBV -1 $r1 -2 $r2 -S ${sample}_NA.sam
        bowtie2 -x $params.MIndexIBV -1 $r1 -2 $r2 -S ${sample}_M.sam
        bowtie2 -x $params.NSIndexIBV -1 $r1 -2 $r2 -S ${sample}_NS.sam 
    fi

    """
    
}

/*
* Step 8. Convert to binary format
*/

process CONVERT_BINARY {
    fair true
    executor 'slurm'
    queue params.queue
    memory params.memory
    cpus params.CPU
    module "${params.samtoolsMod}"
    
    input:
    tuple path(PB2), path(PB1), path(PA), path(HA), path(NP), path(NA), path(M), path(NS)
    val sample
    
    output:
    tuple path("${sample}_PB2.bam"), path("${sample}_PB1.bam"), path("${sample}_PA.bam"), path("${sample}_HA.bam"), path("${sample}_NP.bam"), path("${sample}_NA.bam"), path("${sample}_M.bam"), path("${sample}_NS.bam")

    script:
    """
    
    samtools view $PB2 -o ${sample}_PB2.bam
    samtools view $PB1 -o ${sample}_PB1.bam
    samtools view $PA -o ${sample}_PA.bam
    samtools view $HA -o ${sample}_HA.bam
    samtools view $NP -o ${sample}_NP.bam
    samtools view $NA -o ${sample}_NA.bam
    samtools view $M -o ${sample}_M.bam
    samtools view $NS -o ${sample}_NS.bam

    """
    
}

/*
* Step 9. Sort aligned reads
*/

process SORT_READS {
    fair true
    executor 'slurm'
    queue params.queue
    memory params.memory
    cpus params.CPU
    module "${params.samtoolsMod}"
    publishDir "${params.projectPath}/aligned", mode: 'copy'
    
    input:
    tuple path(PB2), path(PB1), path(PA), path(HA), path(NP), path(NA), path(M), path(NS)
    val sample
    
    output:
    tuple path("${sample}_PB2.sorted.bam"), path("${sample}_PB1.sorted.bam"), path("${sample}_PA.sorted.bam"), path("${sample}_HA.sorted.bam"), path("${sample}_NP.sorted.bam"), path("${sample}_NA.sorted.bam"), path("${sample}_M.sorted.bam"), path("${sample}_NS.sorted.bam")

    script:
    """
    
    samtools sort $PB2 -o ${sample}_PB2.sorted.bam
    samtools sort $PB1 -o ${sample}_PB1.sorted.bam
    samtools sort $PA -o ${sample}_PA.sorted.bam
    samtools sort $HA -o ${sample}_HA.sorted.bam
    samtools sort $NP -o ${sample}_NP.sorted.bam
    samtools sort $NA -o ${sample}_NA.sorted.bam
    samtools sort $M -o ${sample}_M.sorted.bam
    samtools sort $NS -o ${sample}_NS.sorted.bam

    """
    
}

/*
* Step 10. Add read names (necessary for upcoming picard deduplication)
*/

process NAME_READS {
    fair true
    executor 'slurm'
    queue params.queue
    memory params.memory
    cpus params.CPU
    module "${params.samtoolsMod}"
    
    input:
    tuple path(PB2), path(PB1), path(PA), path(HA), path(NP), path(NA), path(M), path(NS)
    val sample
    
    output:
    tuple path("${sample}_PB2_named.sorted.bam"), path("${sample}_PB1_named.sorted.bam"), path("${sample}_PA_named.sorted.bam"), path("${sample}_HA_named.sorted.bam"), path("${sample}_NP_named.sorted.bam"), path("${sample}_NA_named.sorted.bam"), path("${sample}_M_named.sorted.bam"), path("${sample}_NS_named.sorted.bam")

    script:
    """
    samtools addreplacerg -r "@RG\tID:ReadGroup1\tSM:${sample}\tPL:Illumina\tLB:${sample}_PB2.fa" -o ${sample}_PB2_named.sorted.bam $PB2
    samtools addreplacerg -r "@RG\tID:ReadGroup1\tSM:${sample}\tPL:Illumina\tLB:${sample}_PB1.fa" -o ${sample}_PB1_named.sorted.bam $PB1
    samtools addreplacerg -r "@RG\tID:ReadGroup1\tSM:${sample}\tPL:Illumina\tLB:${sample}_PA.fa" -o ${sample}_PA_named.sorted.bam $PA
    samtools addreplacerg -r "@RG\tID:ReadGroup1\tSM:${sample}\tPL:Illumina\tLB:${sample}_HA.fa" -o ${sample}_HA_named.sorted.bam $HA
    samtools addreplacerg -r "@RG\tID:ReadGroup1\tSM:${sample}\tPL:Illumina\tLB:${sample}_NP.fa" -o ${sample}_NP_named.sorted.bam $NP
    samtools addreplacerg -r "@RG\tID:ReadGroup1\tSM:${sample}\tPL:Illumina\tLB:${sample}_NA.fa" -o ${sample}_NA_named.sorted.bam $NA
    samtools addreplacerg -r "@RG\tID:ReadGroup1\tSM:${sample}\tPL:Illumina\tLB:${sample}_M.fa" -o ${sample}_M_named.sorted.bam $M
    samtools addreplacerg -r "@RG\tID:ReadGroup1\tSM:${sample}\tPL:Illumina\tLB:${sample}_NS.fa" -o ${sample}_NS_named.sorted.bam $NS

    """
    
}

/*
* Step 11. Remove optical duplicates that arise during the sequencing process
*/

process DEDUPLICATE {
    fair true
    executor 'slurm'
    queue params.queue
    memory params.memory
    cpus params.CPU
    module "${params.javaMod}"
    publishDir "${params.projectPath}/aligned", mode: 'copy'
    
    input:
    tuple path(PB2), path(PB1), path(PA), path(HA), path(NP), path(NA), path(M), path(NS)
    val sample
    
    output:
    tuple path("${sample}_PB2_dedup_metrics.txt"), path("${sample}_PB1_dedup_metrics.txt"), path("${sample}_PA_dedup_metrics.txt"), path("${sample}_HA_dedup_metrics.txt"), path("${sample}_NP_dedup_metrics.txt"), path("${sample}_NA_dedup_metrics.txt"), path("${sample}_M_dedup_metrics.txt"), path("${sample}_NS_dedup_metrics.txt"), emit: metrics
    
    tuple path("${sample}_PB2_dedup.sorted.bam"), path("${sample}_PB1_dedup.sorted.bam"), path("${sample}_PA_dedup.sorted.bam"), path("${sample}_HA_dedup.sorted.bam"), path("${sample}_NP_dedup.sorted.bam"), path("${sample}_NA_dedup.sorted.bam"), path("${sample}_M_dedup.sorted.bam"), path("${sample}_NS_dedup.sorted.bam"), emit: dedup_reads

    script:
    """
    java -jar $params.picardPath MarkDuplicates -I $PB2 -M ${sample}_PB2_dedup_metrics.txt -O ${sample}_PB2_dedup.sorted.bam
    java -jar $params.picardPath MarkDuplicates -I $PB1 -M ${sample}_PB1_dedup_metrics.txt -O ${sample}_PB1_dedup.sorted.bam
    java -jar $params.picardPath MarkDuplicates -I $PA -M ${sample}_PA_dedup_metrics.txt -O ${sample}_PA_dedup.sorted.bam
    java -jar $params.picardPath MarkDuplicates -I $HA -M ${sample}_HA_dedup_metrics.txt -O ${sample}_HA_dedup.sorted.bam
    java -jar $params.picardPath MarkDuplicates -I $NP -M ${sample}_NP_dedup_metrics.txt -O ${sample}_NP_dedup.sorted.bam
    java -jar $params.picardPath MarkDuplicates -I $NA -M ${sample}_NA_dedup_metrics.txt -O ${sample}_NA_dedup.sorted.bam
    java -jar $params.picardPath MarkDuplicates -I $M -M ${sample}_M_dedup_metrics.txt -O ${sample}_M_dedup.sorted.bam
    java -jar $params.picardPath MarkDuplicates -I $NS -M ${sample}_NS_dedup_metrics.txt -O ${sample}_NS_dedup.sorted.bam
   
    """
    
}

/*
* Step 12. Call consensus sequences
*/

process BUILD_CONSENSUS {
    fair true
    executor 'slurm'
    queue params.queue
    memory params.memory
    cpus params.CPU
    module "${params.samtoolsMod}"
    module "${params.ivarMod}"
    publishDir "${params.projectPath}/consensus", mode: 'copy'
    
    when:
    params.callConsensus == 'TRUE'
    
    input:
    tuple path(PB2), path(PB1), path(PA), path(HA), path(NP), path(NA), path(M), path(NS)
    val sample
    
    output:
    tuple path("${sample}_PB2.fa"), path("${sample}_PB1.fa"), path("${sample}_PA.fa"), path("${sample}_HA.fa"), path("${sample}_NP.fa"), path("${sample}_NA.fa"), path("${sample}_M.fa"), path("${sample}_NS.fa"), emit: fasta
    
    tuple path("${sample}_PB2.qual.txt"), path("${sample}_PB1.qual.txt"), path("${sample}_PA.qual.txt"), path("${sample}_HA.qual.txt"), path("${sample}_NP.qual.txt"), path("${sample}_NA.qual.txt"), path("${sample}_M.qual.txt"), path("${sample}_NS.qual.txt"), emit: qual

    script:
    """
    
    samtools mpileup -aa -A -d 0 -Q 0 $PB2 | ivar consensus -p ${sample}_PB2 
    samtools mpileup -aa -A -d 0 -Q 0 $PB1 | ivar consensus -p ${sample}_PB1
    samtools mpileup -aa -A -d 0 -Q 0 $PA | ivar consensus -p ${sample}_PA
    samtools mpileup -aa -A -d 0 -Q 0 $HA | ivar consensus -p ${sample}_HA
    samtools mpileup -aa -A -d 0 -Q 0 $NP | ivar consensus -p ${sample}_NP
    samtools mpileup -aa -A -d 0 -Q 0 $NA | ivar consensus -p ${sample}_NA
    samtools mpileup -aa -A -d 0 -Q 0 $M | ivar consensus -p ${sample}_M
    samtools mpileup -aa -A -d 0 -Q 0 $NS | ivar consensus -p ${sample}_NS 
   
    """
    
}

/*
* Step 13. Concatenate segment sequences
*/

process CONCATENATE {
    fair true
    publishDir "${params.projectPath}/consensus", mode: 'copy'
    
    input:
    tuple path(PB2), path(PB1), path(PA), path(HA), path(NP), path(NA), path(M), path(NS)
    val sample
    
    output:
    path("${sample}_fullgenome.fa")

    script:
    """
    
    cat $PB2 $PB1 $PA $HA $NP $NA $M $NS > ${sample}_fullgenome.fa 
   
    """
    
}

/*
* Step 14. Get per-nucleotide depth statistics
*/

process DEPTH_STATS {
    fair true
    executor 'slurm'
    queue params.queue
    memory params.memory
    cpus params.CPU
    module "${params.samtoolsMod}"
    publishDir "${params.projectPath}/depth_stats", mode: 'copy'
    
    when:
    params.callDepth == 'TRUE'
    
    input:
    tuple path(PB2), path(PB1), path(PA), path(HA), path(NP), path(NA), path(M), path(NS)
    val sample
    
    output:
    tuple path("${sample}_PB2_depth.tsv"), path("${sample}_PB1_depth.tsv"), path("${sample}_PA_depth.tsv"), path("${sample}_HA_depth.tsv"), path("${sample}_NP_depth.tsv"), path("${sample}_NA_depth.tsv"), path("${sample}_M_depth.tsv"), path("${sample}_NS_depth.tsv") 

    script:
    """
    
    samtools depth -a $PB2 -o ${sample}_PB2_depth.tsv
    samtools depth -a $PB1 -o ${sample}_PB1_depth.tsv
    samtools depth -a $PA -o ${sample}_PA_depth.tsv
    samtools depth -a $HA -o ${sample}_HA_depth.tsv
    samtools depth -a $NP -o ${sample}_NP_depth.tsv
    samtools depth -a $NA -o ${sample}_NA_depth.tsv
    samtools depth -a $M -o ${sample}_M_depth.tsv
    samtools depth -a $NS -o ${sample}_NS_depth.tsv
   
    """
}

/*
* Step 15. Perform variant-calling relative to the reference sequence and annotate effects
*/

process CALL_VARIANTS {
    fair true
    executor 'slurm'
    queue params.queue
    memory params.memory
    cpus params.CPU
    module "${params.samtoolsMod}"
    module "${params.ivarMod}"
    publishDir "${params.projectPath}/variants", mode: 'copy'
    
    when:
    params.callVariants == 'TRUE'
    
    input:
    tuple path(PB2), path(PB1), path(PA), path(HA), path(NP), path(NA), path(M), path(NS)
    val sample
    val subtype
    
    output:
    tuple path("${sample}_PB2_variants.tsv"), path("${sample}_PB1_variants.tsv"), path("${sample}_PA_variants.tsv"), path("${sample}_HA_variants.tsv"), path("${sample}_NP_variants.tsv"), path("${sample}_NA_variants.tsv"), path("${sample}_M_variants.tsv"), path("${sample}_NS_variants.tsv")
    
    script:
    """
    if [ "$subtype" == "H1N1" ]; then 
        samtools mpileup -aa -A -d 0 -B -Q 0 --reference "${params.PB2IndexH1N1}.fasta" $PB2 | ivar variants -p ${sample}_PB2_variants -q $params.minQual -t $params.minFreq -r "${params.PB2IndexH1N1}.fasta" -g "${params.PB2IndexH1N1}.gff3"
        
        samtools mpileup -aa -A -d 0 -B -Q 0 --reference "${params.PB1IndexH1N1}.fasta" $PB1 | ivar variants -p ${sample}_PB1_variants -q $params.minQual -t $params.minFreq -r "${params.PB1IndexH1N1}.fasta" -g "${params.PB1IndexH1N1}.gff3"
        
        samtools mpileup -aa -A -d 0 -B -Q 0 --reference "${params.PAIndexH1N1}.fasta" $PA | ivar variants -p ${sample}_PA_variants -q $params.minQual -t $params.minFreq -r "${params.PAIndexH1N1}.fasta" -g "${params.PAIndexH1N1}.gff3"
        
        samtools mpileup -aa -A -d 0 -B -Q 0 --reference "${params.HAIndexH1N1}.fasta" $HA | ivar variants -p ${sample}_HA_variants -q $params.minQual -t $params.minFreq -r "${params.HAIndexH1N1}.fasta" -g "${params.HAIndexH1N1}.gff3"
        
        samtools mpileup -aa -A -d 0 -B -Q 0 --reference "${params.NPIndexH1N1}.fasta" $NP | ivar variants -p ${sample}_NP_variants -q $params.minQual -t $params.minFreq -r "${params.NPIndexH1N1}.fasta" -g "${params.NPIndexH1N1}.gff3"
        
        samtools mpileup -aa -A -d 0 -B -Q 0 --reference "${params.NAIndexH1N1}.fasta" $NA | ivar variants -p ${sample}_NA_variants -q $params.minQual -t $params.minFreq -r "${params.NAIndexH1N1}.fasta" -g "${params.NAIndexH1N1}.gff3"
        
        samtools mpileup -aa -A -d 0 -B -Q 0 --reference "${params.MIndexH1N1}.fasta" $M | ivar variants -p ${sample}_M_variants -q $params.minQual -t $params.minFreq -r "${params.MIndexH1N1}.fasta" -g "${params.MIndexH1N1}.gff3"
        
        samtools mpileup -aa -A -d 0 -B -Q 0 --reference "${params.NSIndexH1N1}.fasta" $NS | ivar variants -p ${sample}_NS_variants -q $params.minQual -t $params.minFreq -r "${params.NSIndexH1N1}.fasta" -g "${params.NSIndexH1N1}.gff3" 
    fi
    
    if [ "$subtype" == "H3N2" ]; then 
        samtools mpileup -aa -A -d 0 -B -Q 0 --reference "${params.PB2IndexH3N2}.fasta" $PB2 | ivar variants -p ${sample}_PB2_variants -q $params.minQual -t $params.minFreq -r "${params.PB2IndexH3N2}.fasta" -g "${params.PB2IndexH3N2}.gff3"
        
        samtools mpileup -aa -A -d 0 -B -Q 0 --reference "${params.PB1IndexH3N2}.fasta" $PB1 | ivar variants -p ${sample}_PB1_variants -q $params.minQual -t $params.minFreq -r "${params.PB1IndexH3N2}.fasta" -g "${params.PB1IndexH3N2}.gff3"
        
        samtools mpileup -aa -A -d 0 -B -Q 0 --reference "${params.PAIndexH3N2}.fasta" $PA | ivar variants -p ${sample}_PA_variants -q $params.minQual -t $params.minFreq -r "${params.PAIndexH3N2}.fasta" -g "${params.PAIndexH3N2}.gff3"
        
        samtools mpileup -aa -A -d 0 -B -Q 0 --reference "${params.HAIndexH3N2}.fasta" $HA | ivar variants -p ${sample}_HA_variants -q $params.minQual -t $params.minFreq -r "${params.HAIndexH3N2}.fasta" -g "${params.HAIndexH3N2}.gff3"
        
        samtools mpileup -aa -A -d 0 -B -Q 0 --reference "${params.NPIndexH3N2}.fasta" $NP | ivar variants -p ${sample}_NP_variants -q $params.minQual -t $params.minFreq -r "${params.NPIndexH3N2}.fasta" -g "${params.NPIndexH3N2}.gff3"
        
        samtools mpileup -aa -A -d 0 -B -Q 0 --reference "${params.NAIndexH3N2}.fasta" $NA | ivar variants -p ${sample}_NA_variants -q $params.minQual -t $params.minFreq -r "${params.NAIndexH3N2}.fasta" -g "${params.NAIndexH3N2}.gff3"
        
        samtools mpileup -aa -A -d 0 -B -Q 0 --reference "${params.MIndexH3N2}.fasta" $M | ivar variants -p ${sample}_M_variants -q $params.minQual -t $params.minFreq -r "${params.MIndexH3N2}.fasta" -g "${params.MIndexH3N2}.gff3"
        
        samtools mpileup -aa -A -d 0 -B -Q 0 --reference "${params.NSIndexH3N2}.fasta" $NS | ivar variants -p ${sample}_NS_variants -q $params.minQual -t $params.minFreq -r "${params.NSIndexH3N2}.fasta" -g "${params.NSIndexH3N2}.gff3" 
    fi
    
    if [ "$subtype" == "IBV" ]; then 
        samtools mpileup -aa -A -d 0 -B -Q 0 --reference "${params.PB2IndexIBV}.fasta" $PB2 | ivar variants -p ${sample}_PB2_variants -q $params.minQual -t $params.minFreq -r "${params.PB2IndexIBV}.fasta" -g "${params.PB2IndexIBV}.gff3"
        
        samtools mpileup -aa -A -d 0 -B -Q 0 --reference "${params.PB1IndexIBV}.fasta" $PB1 | ivar variants -p ${sample}_PB1_variants -q $params.minQual -t $params.minFreq -r "${params.PB1IndexIBV}.fasta" -g "${params.PB1IndexIBV}.gff3"
        
        samtools mpileup -aa -A -d 0 -B -Q 0 --reference "${params.PAIndexIBV}.fasta" $PA | ivar variants -p ${sample}_PA_variants -q $params.minQual -t $params.minFreq -r "${params.PAIndexIBV}.fasta" -g "${params.PAIndexIBV}.gff3"
        
        samtools mpileup -aa -A -d 0 -B -Q 0 --reference "${params.HAIndexIBV}.fasta" $HA | ivar variants -p ${sample}_HA_variants -q $params.minQual -t $params.minFreq -r "${params.HAIndexIBV}.fasta" -g "${params.HAIndexIBV}.gff3"
        
        samtools mpileup -aa -A -d 0 -B -Q 0 --reference "${params.NPIndexIBV}.fasta" $NP | ivar variants -p ${sample}_NP_variants -q $params.minQual -t $params.minFreq -r "${params.NPIndexIBV}.fasta" -g "${params.NPIndexIBV}.gff3"
        
        samtools mpileup -aa -A -d 0 -B -Q 0 --reference "${params.NAIndexIBV}.fasta" $NA | ivar variants -p ${sample}_NA_variants -q $params.minQual -t $params.minFreq -r "${params.NAIndexIBV}.fasta" -g "${params.NAIndexIBV}.gff3"
        
        samtools mpileup -aa -A -d 0 -B -Q 0 --reference "${params.MIndexIBV}.fasta" $M | ivar variants -p ${sample}_M_variants -q $params.minQual -t $params.minFreq -r "${params.MIndexIBV}.fasta" -g "${params.MIndexIBV}.gff3"
        
        samtools mpileup -aa -A -d 0 -B -Q 0 --reference "${params.NSIndexIBV}.fasta" $NS | ivar variants -p ${sample}_NS_variants -q $params.minQual -t $params.minFreq -r "${params.NSIndexIBV}.fasta" -g "${params.NSIndexIBV}.gff3" 
    fi
    
    """
    
}

/*
* Workflow
*/

workflow {

    // create channel for paired reads
    read_pairs_ch = Channel.fromFilePairs("${params.fastqPath}/*{R1,R2}*.fastq.gz")
                        .toSortedList( { a, b -> a[0] <=> b[0] } )
                        .flatMap()
                        .map{item -> item[1]}
    
    //create channel for sample names
    sample_ch = Channel.fromPath(params.metaPath)
                .splitCsv(header: true)
                .map{row -> tuple(row.sample, row.subtype)}
                .toSortedList( { a, b -> a[0] <=> b[0] } )
                .flatMap()
                .map{item -> item[0]}
                
    //create channel for sample subtypes
    subtype_ch = Channel.fromPath(params.metaPath)
                .splitCsv(header: true)
                .map{row -> tuple(row.sample, row.subtype)}
                .toSortedList( { a, b -> a[0] <=> b[0] } )
                .flatMap()
                .map{item -> item[1]}
    
    // trim adapters
    TRIM_ADAPTERS(read_pairs_ch, sample_ch)       
    
    //trim 5' MBTUni-12 primers
    CUT_G12(TRIM_ADAPTERS.out, sample_ch)
    
    //trim 5' MBTUni-13 primers
    CUT_G13(CUT_G12.out, sample_ch)
    
    //trim 3' MBTUni-12 primers
    CUT_A12(CUT_G13.out, sample_ch)
    
    //trim 3' MBTUni-13 primers
    CUT_A13(CUT_A12.out, sample_ch)
    
    //filter host sequences
    FILTER_HOST(CUT_A13.out, sample_ch)
    
    //align to viral ref seqs
    ALIGN_VIRUS(FILTER_HOST.out.filtered_fastq, sample_ch, subtype_ch)
    
    //convert aligned reads to binary
    CONVERT_BINARY(ALIGN_VIRUS.out, sample_ch)
    
    //sort aligned reads
    SORT_READS(CONVERT_BINARY.out, sample_ch)
    
    //assign read names
    NAME_READS(SORT_READS.out, sample_ch)
    
    //remove sequencing duplicates
    DEDUPLICATE(NAME_READS.out, sample_ch)
    
    //call consensus sequences
    BUILD_CONSENSUS(DEDUPLICATE.out.dedup_reads, sample_ch)
    
    //concatenate segment sequences
    CONCATENATE(BUILD_CONSENSUS.out.fasta, sample_ch)
    
    //get depth stats
    DEPTH_STATS(DEDUPLICATE.out.dedup_reads, sample_ch)
    
    //perform variant calling
    CALL_VARIANTS(DEDUPLICATE.out.dedup_reads, sample_ch, subtype_ch)
    
}
