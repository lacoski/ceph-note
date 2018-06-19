Mục tiêu PGs
- Quản trị Object được nhân bản trên các OSD.
- Tăng số PG sẽ giảm load OSD (?)

Cách sử dụng PG
- PG tập hợp các object vào pool.
- nội dung Object trong các PG được lưu trong tập các OSD (theo số pool chỉ định)

VD: Đặt Replicate = 2 pool, mỗi PG sẽ lưu số object của nó trong 2 OSD

pic 1

Theo ví dụ, 1 PG nhân bản ra 2 OSD => nếu 1 OSD bị lỗi, dữ liệu OSD kia sẽ sử dụng để backup dữ liệu
=> Chuyển pool = 3 => 1 PG sẽ cần 3 OSD để nhận bản, 1 OSD mới sẽ được gán vào PG để thực hiện quả trình nhân bản dữ liệu

Lưu ý: PG không phải là chủ của OSD, OSD sẽ được chia sẽ với các PGs khác, chung pool hoặc khác pool

Khi tăng PG:
- PG mới sẽ gán với các OSDs
- Thuật toán CRUSH sẽ thay đổi, 1 số object sẽ di chuyển vào PGs mới, dữ liệu sẽ được thay đổi các trên PGs

Qúa trình khắc phục lỗi:
1. Khi OSD lỗi, tất cả bản sao trên OSD bị mất, mức nhân bản PG từ 3-2
2. Ceph thực hiện quá trình khôi phục, PG sẽ chọn OSD mới, đưa vào PGs, thực hiện quá trình nhân bản
3. Trường hợp xấu, OSD thứ trong PGs chết (chết 2/3) trước khi OSD được đừa vào cụm => Dữ liệu nguy hiểm (chỉ còn 1 bản backup)
4. Ceph tiếp tục chọn OSD khác, đưa vào PG, bảo đảm mức nhân bản
5. Khi OSD (3/3) chết trong cùng PG trước khi quá trình backup diễn ra => dữ liệu mất vĩnh viễn

VD: 10 OSD
Cluster bao gồm 10 OSD, 512 PGs, 3 repica pool
- CRUSH sẽ phân tích mỗi PGs 3 OSD
- Sau khi phân chia xong, mỗi OSD sẽ chứa (512*3)/10 = 150 PGs
=> Khi 1 OSD lỗi, kịch bản sẽ khôi phục 150 PGs trên cùng 1 thời điểm
=> 150 PGs còn lại sẽ nằm trên 9 OSD còn lại.

VD:Cluster có 10->20 OSDs với 512 PGs, mức nhân bản 3
- CRUSH gán mỗi PG 3 OSDs
- Kết thúc, (512*3)/20 = (150 -> 75) PGs
- Mỗi 1 OSD lỗi => 19 OSD sẽ backup lại dữ liêu
=> OSD lỗi = 1 TB => 10 OSD giữa 100GB (đủ 1 TB OSD lỗi) => càng nhiều OSD tốc độ backup càng cao.

VD: Cluster 40 OSD, 512 PGs, 3 repical pool
- Crush gán 3 OSD mỗi PG
- Sau tính toán, mỗi OSD chứa (512*3)/40 = 35 - 40 PGs
=> 1 OSD lỗi (1TB data) => 39 OSD còn lại sẽ backup
=> Dung lượng Backup mỗi OSD = 1000 / 39 ~ 25 GB mỗi OSD
=> Quá trình backup diễn ra càng nhanh khi có nhiều OSD

VD: 200 OSD, 512 PGs, 3 repi pool
- CRUSH gán mỗi PG 3 OSD
- Sau tính toán, mỗi OSD chứa 7 PGs
- Khi 1 OSD lỗi, 7*3 OSD sẽ diễn ra hoạt động backup
=> Dung lượng backup trên 21 OSD = 1000/21 ~~ 47 GB (nhanh hơn so với 10 PG)

> Cơ bản càng nhiều OSD, quá trình backup diễn ra càng nhanh, nguy cơ mất dữ liệu càng thấp

# Vấn đề
Trong trường hợp 1 PG - 10 OSD - 3 repli pool
=> Chỉ có 3 OSD sử dụng (1*10/3 =~ 3)
=> số OSD còn lại sẽ không được sử dụng

=> Nếu có nhiều hơn 50 OSD, số PG yêu cầu cơ bản từ 50 - 100 PGs trên mỗi OSD
CT:
```
total PGs = (OSD*100)/(pool size)
```

Chọn lựa số PGs:
- nhỏ hơn 5 OSD => set pg_num = 128
- 5-10 OSD => set pg_num = 512
- 10-50 OSD => set pg_num = 4096

CMD:
```
ceph osd pool set {pool-name} pg_num
```

VD: cluster bao gồm 160 OSD, 3 repli
=> total PGs = (OSD * 100)/3 = (160*100)/3 = 5333.333 => làm tròn 8192 (2^n > 5333)

# PG vs PGP
PGP is the PG for Placement purpose, which should be kept equal to the total number of PGs

Bước 1: Kiểm tra số PG vs PGP
```
ceph osd pool get data-pool pg_num
ceph osd pool get data-pool pgp_num
```

Bước 2:
- ceph osd dump | grep size
```
Total OSD number = 9, replication pool size = 2, Pool count = 3

Total PGs = (OSDs * 100)/(pool size) = (9*100)/2 = 450

PG / Pool = Total PGs / pool count = 450/3 = 150 ~ 256 PG
```

Step 3: Set the PG and PGP number for all other pool
```
ceph osd pool set data-pool pg_num  256
ceph osd pool set data-pool pgp_num 256
```


# Giám sát OSDs
Các trạng thái OSD:
```
in: in the cluster
out: out of the cluster
up: up and running
down: not running
```

Ceph is NOT Healthy_OK
```
You haven't started the cluster yet
The OSDs are in the peering when you just started/restart the cluster
You just added/removed an OSD
You just have modified your cluster map
```

CMD:
```
ceph osd stat
---------------------
Check how many OSDs
Check how many are up
Check how many are in
```

```
ceph osd tree
--------------
Identify the ceph-osd daemons that aren't running
```

```
sudo /etc/init.d/ceph -a start osd.1
------------------------------------
Start an OSD, if it down
```

# Khi OSD chuyển trọng thái down
- Khi thêm và xóa OSD => Ceph sẽ gán lại PGs tới OSDs khác
- Khi OSD down, hoặc khởi động lại => ceph sẽ chạy quá trình recovering
- OSD chuyển trạng thái down, không thể khởi động => 1 OSD khác sẽ thay thế OSD chét

# Up Set
Up Set: tập các OSDs đang xử lý requests

```
Ceph is migrating Data
An OSD is recovering
The cluster is rebalancing itself
Problem: HEALTHY WARN with "stuck state"
```

# Check PG Status
List of PG
```
ceph pg dump
```

To view which OSDs are within the Acting Set or the Up Set
```
ceph pg map {pg-num}
```

Check PG Stat
```
ceph pg stat
```

# List Pool
```
ceph osd lspools
```
