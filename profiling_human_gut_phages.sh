#!/bin/bash
export PATH="/hwfssz5/ST_INFECTION/GlobalDatabase/user/fengqikai/software/.conda/envs/Trinity-2.11.0/bin/:$PATH"

GPD_index="/ldfssz1/ST_INFECTION/P20Z10200N0206_pathogendb/liqian6/fece_meta/GPD_index"
inputpath="/ldfssz1/ST_INFECTION/P20Z10200N0206_pathogendb/liqian6/fece_meta/2017_fece_samples"
outputdir1="/ldfssz1/ST_INFECTION/P20Z10200N0206_pathogendb/liqian6/fece_meta/test_all_phages"
samplelist="/ldfssz1/ST_INFECTION/P20Z10200N0206_pathogendb/liqian6/fece_meta/seleted_phages_test/samplelist.txt.test"
genomelist="/ldfssz1/ST_INFECTION/P20Z10200N0206_pathogendb/liqian6/fece_meta/genome.list"

while read sample

do

echo -e "mapping $sample to GPD genomes at $(date)" 
mkdir $outputdir1/${sample// /}
/hwfssz5/ST_INFECTION/GlobalDatabase/user/fengqikai/software/.conda/envs/Trinity-2.11.0/bin/bowtie2 -N 1 -p 32 -x $GPD_index -1 $inputpath/${sample// /}.rmhost.1.fq.gz -2 $inputpath/${sample// /}.rmhost.2.fq.gz -S $outputdir1/${sample// /}/${sample// /}.sam

outputdir="$outputdir1/${sample// /}"

echo -e "generating bam files for $sample"
/hwfssz5/ST_INFECTION/GlobalDatabase/user/fengqikai/software/.conda/envs/Trinity-2.11.0/bin/samtools view -b -S -@ 32 $outputdir1/${sample// /}/${sample// /}.sam > $outputdir1/${sample// /}/${sample// /}.bam

echo -e "start sorting on  $sample" 
#sort a BAM file
cat $outputdir/${sample// /}.bam  | /hwfssz5/ST_INFECTION/GlobalDatabase/user/fengqikai/software/.conda/envs/Trinity-2.11.0/bin/samtools sort -@ 4 -o $outputdir/${sample// /}_sorted.bam

#get comprehensive statistics
echo -e "start generating stats from  $sample" 
/hwfssz5/ST_INFECTION/GlobalDatabase/user/fengqikai/software/.conda/envs/Trinity-2.11.0/bin/samtools stats -@ 8 $outputdir/${sample// /}_sorted.bam > $outputdir/${sample// /}_sorted.stats

#get coverage
echo -e "start generating indice for  $sample" 
/hwfssz5/ST_INFECTION/GlobalDatabase/user/fengqikai/software/.conda/envs/Trinity-2.11.0/bin/samtools index -@ 8 $outputdir/${sample// /}_sorted.bam $outputdir/${sample// /}_sorted.bai

rm $outputdir1/${sample// /}/${sample// /}.sam 

#calculate average coverage
echo -e "start generating coverage on  $sample" 
/zfssz2/ST_MCHRI/COHORT/fengqikai/software/bedtools2/bedtools2/bin/bedtools bamtobed -i $outputdir/${sample// /}_sorted.bam > $outputdir/${sample// /}_sorted.bed


/zfssz2/ST_MCHRI/COHORT/fengqikai/software/bedtools2/bedtools2/bin/bedtools genomecov -i $outputdir/${sample// /}_sorted.bed  -g $genomelist  > $outputdir/${sample// /}_cov.txt

rm $outputdir/${sample// /}.bam

echo -e "$sample finished at $(date)"

#rm $outputdir/${sample// /}_sorted.bam
done < $samplelist

echo -e "job completed"
date
