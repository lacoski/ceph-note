#!/bin/bash

IODEPTH=64
DISK_CHECK=( "testfile" )
TYPE_TEST=("randread" "randwrite")
BLOCK_TEST=("4K" "8K")
SIZE=4G
RESULT_DIR="fio-results"

red=`tput setaf 1`
green=`tput setaf 2`
reset=`tput sgr0`

mkdir ${RESULT_DIR}

# read, write random
for loop in 1 2 3 
do
    for disk in "${DISK_CHECK[@]}"
    do      
        for type_test in "${TYPE_TEST[@]}"
        do    
            for blocksize in "${BLOCK_TEST[@]}"
            do  
                echo -e "\n"
                echo "[${green} Notification ${reset}] Test ${disk} ${type_test} ${blocksize} " && sleep 2s
                fio --randrepeat=1 --ioengine=libaio --direct=1 --gtod_reduce=1 --name=${type_test}_${blocksize} --readwrite=${type_test} --size=${SIZE} --iodepth=${IODEPTH} --filename=${disk} \
                --bs=${blocksize} --output=${RESULT_DIR}/${type_test}_${blocksize}_`hostname`_${loop}.txt
                rm -rf testfile
            done
        done
    done


    # read, write seq
    for disk in "${DISK_CHECK[@]}"
    do 
        fio --name=read_seq --readwrite=read --size=${SIZE} --filename=${disk} --output=${RESULT_DIR}/read_seq_`hostname`_${loop}.txt
        rm -rf testfile

        fio --name=write_seq --readwrite=write --size=${SIZE} --filename=${disk} --output=${RESULT_DIR}/write_seq_`hostname`_${loop}.txt
        rm -rf testfile
    done
done