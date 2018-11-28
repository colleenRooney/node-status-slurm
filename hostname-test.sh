#!/usr/bin/bash
# 2018 Colleen Rooney

OUTPUT_DIR=hostname-output

nodes=( $(./get-idle-nodes.py -v -p medium) )
num_idle_array=${#nodes[@]}

cp hostname.sh temp.sh

num_idle_array="$(($num_idle_array))"

for (( i=0; i<${#nodes[@]}; i+=2)) ;
do
    node=${nodes[$i]}
    partition=${nodes[$i + 1]}
    name="${node//[0-9]/}"
    sed "s/NODE/$node/; s/PARTITION/$partition/" temp.sh > temp_sub.sh
    sbatch temp_sub.sh
done

rm temp_sub.sh temp.sh

echo $files
while [  $(ls hostname-output | wc -l) -lt $num_idle_array ];
do
    echo waiting for output
done

for log in $OUTPUT_DIR/*.log;
do
    # remove log files
    rm $log 
done

for err in $OUTPUT_DIR/*.err;
do
    size=( $(stat --printf="%s" $err) )
    if [[ $size == '0' ]]
    then
	# remove empty error files
	rm $err
    else
	# prints nodes that have errors to terminal
	echo $err | cut -d'-' -f 2 | cut -d'/' -f 2
    fi
    
done
