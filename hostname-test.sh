#!/usr/bin/bash
# 2018 Colleen Rooney

OUTPUT_DIR=hostname-output

nodes=( $(./get-idle-nodes.py -v) )
num_idle_array=${#nodes[@]}

mkdir -p $OUTPUT_DIR
rm -rf $OUTPUT_DIR/*
cp hostname.sh temp.sh

for (( i=0; i<$num_idle_array; i+=2)); do
    node=${nodes[$i]}
    partition=${nodes[$i + 1]}
    name="${node//[0-9]/}"
    sed "s/NODE/$node/; s/PARTITION/$partition/" temp.sh > temp_sub.sh
    sbatch temp_sub.sh
done

rm temp_sub.sh temp.sh

while [  $(ls hostname-output | wc -l) -lt $num_idle_array ]; do
    echo waiting for output
done

rm $OUTPUT_DIR/*.log

echo
echo Nodes that produced errors:
for err in $OUTPUT_DIR/*.err; do
    size=( $(stat --printf="%s" $err) )
    if [[ $size == '0' ]] 
    then
	rm $err
    else
	echo $err | cut -d'-' -f 2 | cut -d'/' -f 2
    fi
    
done
