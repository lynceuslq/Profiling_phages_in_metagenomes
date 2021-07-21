#!/bin/bash

BOWTIE2="/PATH/TO/bowtie2"
SAMTOOLS="/PATH/TO/samtools"
BEDTOOLS="/PATH/TO/bedtools"
GPD_index="/PATH/TO/phage_genome_bowrie2_index"
inputpath="/PATH/TO/metagenomic_samples"
outputdir1="/PATH/TO/ouput"
samplelist="/PATH/TO/samplelist.txt"
genomelist="/PATH/TO/phage_genome.list"

while read sample

do

echo -e "mapping $sample to GPD genomes at $(date)" 
mkdir $outputdir1/${sample// /}
$BOWTIE2 -N 1 -p 32 -x $GPD_index -1 $inputpath/${sample// /}.rmhost.1.fq.gz -2 $inputpath/${sample// /}.rmhost.2.fq.gz -S $outputdir1/${sample// /}/${sample// /}.sam

outputdir="$outputdir1/${sample// /}"

echo -e "generating bam files for $sample"
$SAMTOOLS view -b -S -@ 32 $outputdir1/${sample// /}/${sample// /}.sam > $outputdir1/${sample// /}/${sample// /}.bam

echo -e "start sorting on  $sample" 
#sort a BAM file
cat $outputdir/${sample// /}.bam  | $SAMTOOLS sort -@ 4 -o $outputdir/${sample// /}_sorted.bam

#get comprehensive statistics
echo -e "start generating stats from  $sample" 
$SAMTOOLS stats -@ 8 $outputdir/${sample// /}_sorted.bam > $outputdir/${sample// /}_sorted.stats

#get coverage
echo -e "start generating indice for  $sample" 
$SAMTOOLS index -@ 8 $outputdir/${sample// /}_sorted.bam $outputdir/${sample// /}_sorted.bai

rm $outputdir1/${sample// /}/${sample// /}.sam 

#calculate average coverage
echo -e "start generating coverage on  $sample" 
$BEDTOOLS bamtobed -i $outputdir/${sample// /}_sorted.bam > $outputdir/${sample// /}_sorted.bed


$BEDTOOLS genomecov -i $outputdir/${sample// /}_sorted.bed  -g $genomelist  > $outputdir/${sample// /}_cov.txt

rm $outputdir/${sample// /}.bam

echo -e "$sample finished at $(date)"

#rm $outputdir/${sample// /}_sorted.bam
done < $samplelist

echo -e "job completed at $(date)"
date
