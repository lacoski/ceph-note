# read seq 4k
fio --rw=read --size=5g --filename=testfile --name=read-seq --bs=4k

# write seq 4k
fio --rw=write --size=5g --filename=testfile --name=write-seq

# write ran 4k
fio --rw=randread --ioengine=libaio --size=5g --filename=testfile --name=read-ran --direct=1 --gtod_reduce=1 \
    --bs=4k --iodepth=64
