# Benmark disk 
---
## Công cụ vdbench 

### Parameter definition

Vdbench has three basic definitions in the configuration file.
1. SD or storage definition: This defines what storage to use for the testing.
2. WD or workload definition: This defines the workload parameter for the testing.
3. RD or run definition: This defines storage, workload and run duration.

### Storage definition

SD định nghĩa storage sử dụng cho testing. SD name định danh ổ đĩa

```
sd=default,size=100g
sd=sd1,lun=/dev/sdb0
sd=sd2,lun=/dev/sdb1,size=100g
sd=sd3,lun=/dev/sdb2,size=200g
```

### Workload definition

WD định nghĩa workload sử dụng cho test. 

```
sd - Test device
seekpct - Percentage time to move location
rdpct - Read percentage
xfersize - Transfer size
skew - Percentage of skew this workload receives from the total I/O rate
wd - Default setup for the workload
threads - How many concurrent operations for this workload
hotband - Executes hot band workload against a range of storage
```

VD:
> wd=hotwd_uniform,skew=6,sd=sd*,seekpct=100,rdpct=50 wd=hotwd_hot1,sd=sd*,skew=28,seekpct=rand,hotband=(10,18)


### Run definition

RD định nghĩa storage sử dụng cho việc test, và thời gian test

```
wd - Workload load definition
iorate - Either IOPS, max or curve
warmup - Warm-up time that will be excluded from the elapsed time (10s/2m/1h)
elapsed - How long to run
interval - Stats collection interval
threads - Number of threads
forrdpct - Range of percentage read to execute
```

VD:
> rd=rd1_hband,wd=HOTwd*,iorate=MAX,warmup=30,elapsed=6H,interval=10,pause=30,th=200 rd=rd1_seq,wd=wd_seq,iorate=max,forrdpct=(0,100),xfer=256K,warmup=30,el=20m,in=5,th=20


### VD Mẫu:

```
// SD: Storage Definition 
// WD: Workload Definition 
// RD: Run Definition
 
sd=sd1,lun=/dev/sdb0
wd=rr,sd=sd1,xfersize=4096,rdpct=100
rd=run1,wd=rr,iorate=100,elapsed=10,interval=1
 
// Single raw disk, 100% random read of 4k records at i/o rate * of 100 for 10 seconds
```

Chạy scripts
```
/vdbench/vdbench -f conf1.txt conf2.txt -o output+
/vdbench/vdbench -i 10 -f simple_test.conf -o simple_test+
```

Parameters include:
```
-f - Configuration file(s)
-o - Output directory
-e - Elapsed time override
-i - Interval time to override
-w - Warm-up time to override
-j - Activates data validation and journaling
```

### Reports
```
Summary.html - Reports the total workload generated for each interval.
Totals.hml - Reports only the total without detailed interval information.
Logfile.html - Reports Vdbench logging information for debugging.
Kstat.html - kstat statistics (only on Solaris).
Histogram.html - Reports distribution of response times for both reads and writes combined.
Flatfile.html - Performance data file, which can be used to generate performance charts.
```