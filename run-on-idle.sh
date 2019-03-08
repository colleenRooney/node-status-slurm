#!/usr/bin/bash
# 2019 Colleen Rooney

PWD=( $(pwd) )
OUTPUT_DIR=/scratch/utils/test-nodes-output
SCRIPT_BOOL=0

# ====================================================================================
# PARSE OPTIONS
while test $# -gt 0;
do
    case "$1" in
        -h|--help)
            echo "run-on-idle.sh - runs an sbatch script on all idle nodes"
            echo "usage: run-on-idle.sh -s sbatch-script [-h] [-o OUTPUT_DIR]"
            echo " "
            echo "required arguments:"
            echo "-s, --script     sbatch script to run on idle nodes"
            echo " "
            echo "optional arguments:"
            echo "-h, --help       show this message and exit"
            echo "-o, --outdir     specify an output directory"
            echo "                 default: /scratch/utils/test-nodes-output"
            exit 0
            ;;
        -o|--outdir)
            shift
            if test $# -gt 0;
            then
                OUTPUT_DIR=$1
            else
                echo "no output directory specified"
                exit 1
            fi
            shift
            ;;
        -s|--script)
            shift
            if test $# -gt 0;
            then
                SCRIPT=$1
            else
                echo "no script specified"
                exit 1
            fi
            SCRIPT_BOOL=1
            shift
            ;;
    esac
done

if [ $SCRIPT_BOOL -eq 0 ];
then
    echo "please specify a script"
    exit 1
fi

if [[ $OUTPUT_DIR == ~* ]] ;
then
    echo "Invalid output directory"
    exit 1
elif [ -d "$OUTPUT_DIR" ];
then
    echo "$OUTPUT_DIR exists, specify a directory to be created"
    exit 1
fi

# ====================================================================================
# GET IDLE NODES AND RUN SBATCH SCRIPT ON EACH
nodes=( $(./list-nodes.py -v) )
num_idle_array=${#nodes[@]}

mkdir -p $OUTPUT_DIR
cp $SCRIPT temp.sh

for (( i=0; i<$num_idle_array; i+=2)) ;
do
    node=${nodes[$i]}
    partition=${nodes[$i + 1]}
    name="${node//[0-9]/}"
    sed "s:NODE:$node:g; s:PARTITION:$partition:g; s:OUTPUT:$OUTPUT_DIR:g" temp.sh > temp_sub.sh
    sbatch temp_sub.sh
done

rm temp_sub.sh temp.sh

# ====================================================================================
# WAIT FOR OUTPUT AND PRINT NODES THAT LEFT .err FILES
while [  $(ls $OUTPUT_DIR | wc -l) -lt $num_idle_array ] ;
do
    echo waiting for output
    sleep 5
done

rm $OUTPUT_DIR/*.log

echo
echo Nodes that produced errors:
for err in $OUTPUT_DIR/*.err ;
do
    size=( $(stat --printf="%s" $err) )
    if [[ $size == '0' ]] ;
    then
        rm $err
    else
        echo $err | cut -d'-' -f 2 | cut -d'/' -f 2
    fi
done

echo "Remove output directory? (y/n) "
read response

if [ $response = "y" ] ;
then
    rm -rf $OUTPUT_DIR
fi
