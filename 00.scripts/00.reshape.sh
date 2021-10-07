#!/bin/bash
#script to reshape the data
nrep=$1 #number of rep (available in script 01_scripts/models/model_parallel.sh)

rm simul.incomplete
rm comptage*
rm  list.model.tmp

ls -d 03.results/*/ |sed -e 's/03.results\///g' -e 's/.[0-9]_[0-9].//g' -e 's/[\/.]//g' |uniq > list.model.tmp

for i in $(cat list.model.tmp ) ;
do
    wc -l 03.results/$i.*/ABCstat.txt >> comptage.$i.abc
    wc -l 03.results/$i.*/priorfile.txt >> comptage.$i.prior
done

for i in $(cat list.model.tmp ) ;
do
    awk -v var=$nrep '$1!=var {print $2}' comptage.$i.abc |\
        grep -v "total" |\
     sed 's/\/ABCstat.txt//g' >> simul.incomplete
done

mkdir INCOMPLET
for i in $(cat simul.incomplete ) ; do mv $i INCOMPLET ; done


for i in  $(cat list.model.tmp) ; do
    mkdir 03.results/"$i".glob
    mv 03.results/"$i".* 03.results/"$i".glob ;
    for k in $(find 03.results/"$i".glob -name ABCstat.txt) ; do
        cat "$k" |grep -v dataset >> 03.results/"$i".ABC.stat.txt ;
    done
   for k in $(find 03.results/$i.glob -name priorfile.txt) ; do
       cat "$k" |grep -v N_popA >> 03.results/"$i".priorfile1.txt ;
   done ;
done

sed -i '/^$/d' 03.results/*.ABC.stat.txt

for j in  *.glob ; do
       rm 03.results/$j/*/bpfile \
          03.results/$j/*/seedms ;
done

exit


