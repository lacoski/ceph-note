#!/bin/bash
IODEPTH=64
DISK_CHECK=( "/dev/sdb" "/dev/sdc" )
TYPE_TEST=("randread" "randwrite")
BLOCK_TEST=("4K" "8K")
SIZE=4G

red=`tput setaf 1`
green=`tput setaf 2`
reset=`tput sgr0`

for disk in "${DISK_CHECK[@]}"
do      
    for type_test in "${TYPE_TEST[@]}"
    do    
        for blocksize in "${BLOCK_TEST[@]}"
        do  
            echo -e "\n"
            echo "[${green} Notification ${reset}] Test ${disk} ${type_test} ${blocksize} " && sleep 2s
            fio --randrepeat=1 --ioengine=libaio --direct=1 --gtod_reduce=1 --name=${type_test}_${blocksize} --readwrite=${type_test} --size=${SIZE} --iodepth=${IODEPTH} --filename=${disk} --bs=${blocksize}
        done
    done
done