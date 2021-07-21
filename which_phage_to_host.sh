#!bin/bash

export PATH=/hwfssz5/ST_INFECTION/GlobalDatabase/user/liqian6/tools/ncbi-blast-2.10.1+/bin:$PATH
export PATH="/hwfssz5/ST_INFECTION/GlobalDatabase/user/fengqikai/software/.conda/envs/Trinity-2.11.0/bin/:$PATH"

Input="/ldfssz1/ST_INFECTION/P20Z10200N0206_pathogendb/liqian6/bacterial_genome"
Output="/ldfssz1/ST_INFECTION/P20Z10200N0206_pathogendb/liqian6/bacterial_genome"
Blastdb="/ldfssz1/ST_INFECTION/P20Z10200N0206_pathogendb/liqian6/GPD/gut_phage_database/GPD_blastdatabase/GPD"
Listofgenomes="/ldfssz1/ST_INFECTION/P20Z10200N0206_pathogendb/liqian6/bacterial_genome/genomelist.txt"

############################################################you do not need to change anything below########################################################################

while read genome1
do

echo -e "start working on $genome1"

/hwfssz5/ST_INFECTION/GlobalDatabase/user/liqian6/tools/minced-master/minced -spacers $Input/${genome1// /}

genome=$(echo -e "$genome1" | rev | cut -d "." -f2- | rev)

echo -e "start blastn of $genome spacers on GPD at $(date)"

blastn -task blastn-short  -gapopen 10 -gapextend 2 -penalty "-1" -word_size 7 -perc_identity 100 -db $Blastdb -query $Input/${genome// /}_spacers.fa -outfmt "6 qseqid sseqid length qlen slen qstart qend sstart send mismatch gapopen pident evalue bitscore" -out $Output/${genome// /}_spacers.fmt6

awk '$3 ==$4' $Output/${genome// /}_spacers.fmt6 > $Output/${genome// /}_spacers.fmt6.fullycovered

echo -e "done with $genome spacers at $(date)"

cut -f2 $Output/${genome// /}_spacers.fmt6.fullycovered | sort | uniq > $Output/${genome// /}.hostedby.list

done < $Listofgenomes

echo -e "job completed"
date
