# centos 

wget http://dl.fedoraproject.org/pub/epel/7/x86_64/e/epel-release-7-9.noarch.rpm

rpm -ivh epel-release-7-9.noarch.rpm

yum install fio -y

yum install java-1.8.0-openjdk-devel -y 

# ubuntu

sudo apt install fio -y

sudo apt install openjdk-9-jdk

# demo cmd

fio --randrepeat=1 --ioengine=libaio --direct=1 --gtod_reduce=1 --name=test --readwrite=randread --size=4G --iodepth=64 --filename=testfile --bs=4k --output=demo-result.csr --output-format=terse

fio --rw=read --size=5g --filename=testfile --name=read-seq --bs=4k

