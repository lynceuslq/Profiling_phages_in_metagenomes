#!bin/bash

export PATH=/PATH/TO/ncbi-blast-2.10.1+/bin:$PATH
export PATH="/PATH/TO/python/:$PATH"
MINCED="/PATH/TO/minced"

Input="/PATH/TO/bacterial_host_genome"
Output="/PATH/TO/workingdirectory"
Blastdb="/PATH/TO/phage_genome_blast_index"
Listofgenomes="/PATH/TO/bacterial_genomelist.txt"

############################################################you do not need to change anything below########################################################################

while read genome1
do

echo -e "start working on $genome1"

$MINCED -spacers $Input/${genome1// /}

genome=$(echo -e "$genome1" | rev | cut -d "." -f2- | rev)

echo -e "start blastn of $genome spacers on GPD at $(date)"

blastn -task blastn-short  -gapopen 10 -gapextend 2 -penalty "-1" -word_size 7 -perc_identity 100 -db $Blastdb -query $Input/${genome// /}_spacers.fa -outfmt "6 qseqid sseqid length qlen slen qstart qend sstart send mismatch gapopen pident evalue bitscore" -out $Output/${genome// /}_spacers.fmt6

awk '$3 ==$4' $Output/${genome// /}_spacers.fmt6 > $Output/${genome// /}_spacers.fmt6.fullycovered

echo -e "done with $genome spacers at $(date)"

cut -f2 $Output/${genome// /}_spacers.fmt6.fullycovered | sort | uniq > $Output/${genome// /}.hostedby.list

done < $Listofgenomes

echo -e "job completed"
date
