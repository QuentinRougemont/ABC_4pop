#!/bin/bash

##python3 ./ABC_4pop.py SI_1N none 2000

# Global variables
ID=$1
FOLDER=$2
FOLDER="$FOLDER"_"$ID"
MODEL=$3
MIG=$4
NREPS=400
BPFILE=../../bpfile
echo $MODEL
echo $MIG
# Create folder and move into it
mkdir "$FOLDER" 2>/dev/null
cd "$FOLDER"
pwd
# Copy bpfile and spinput.txt
cp "$BPFILE" .

NLOC=$(awk '{print NF}' $BPFILE| sed -n 2p )
TOTALREP=$(echo $(( $NLOC * $NREPS )) )

python3 ../../bin/priorgen_4pop_mig.py $MODEL $MIG $NREPS | \
    ../../bin/msnsam tbs $TOTALREP -t tbs -r tbs tbs \
	-I 4 tbs tbs tbs tbs 0 \
	-n 1 tbs \
	-n 2 tbs \
	-n 3 tbs \
	-n 4 tbs \
	-m 1 2 tbs \
	-m 2 1 tbs \
	-m 3 4 tbs \
	-m 4 3 tbs \
	-m 1 3 tbs \
	-m 3 1 tbs \
	-m 2 4 tbs \
	-m 4 2 tbs \
	-em tbs 1 3 0 \
	-em tbs 3 1 0 \
	-em tbs 2 4 0 \
	-em tbs 4 2 0 \
	-ej tbs 2 1 \
	-en tbs 1 tbs \
	-ej tbs 4 3 \
	-en tbs 3 tbs \
	-ej tbs 3 1 \
	-eN tbs tbs |\
   ../../bin/mscalc_Dfoil.py   

exit



