# Thao tác quản trị Ceph
---
## Thêm tiến trình Monitor - ADDING A MONITOR
> Cần chia sẻ key /etc/ceph/ceph.client.admin.keyring

> Cần chia sẻ file cấu hình /etc/ceph/ceph.conf (đồng bộ trên tất cả các Node Ceph)

> Sử dụng key trên cho bước chứng thực

> Nên reboot lại node monitor sau khi thiết lập để có thể thao tác với trạng thái node

### Bước 1: Truy cập node cần tạo tiến trình
```
ssh root@<node>
```

### Bước 2: Tạo thư mục chứa tiến trình Monitor.
```
sudo mkdir /var/lib/ceph/mon/ceph-{mon-id}

VD:
mkdir /var/lib/ceph/mon/ceph-mon-1
```

### Bước 3: Tạo tiến trình Monitor
Lấy khóa (keyring) cho tiến trình Monitor, ở đây {tmp} là đường dẫn tới khóa tạm, {key-filename} là tên của file chứa khóa monitor
```
ceph auth get mon. -o {tmp}/{key-filename}

VD:
ceph auth get mon. -o /tmp/ceph.mon.keyring
```

Lấy monitor map, ở đây {tmp} là đường dẫn tới khóa tạm, {map-filename} là tên của file chứa monitor map.
```
ceph mon getmap -o {tmp}/{map-filename}

VD:
ceph mon getmap -o /tmp/monmap
```

Chuẩn bị thư mục chứa dữ liệu tiến trình monitor (Vừa tạo) . Lưu ý đường dẫn của monitor map và monitor keyring, chúng rất quan trọng khi tạo tiến trình:
```
sudo ceph-mon -i {mon-id} --mkfs --monmap {tmp}/{map-filename} --keyring {tmp}/{key-filename}

VD:
sudo ceph-mon -i mon-1 --mkfs --monmap /tmp/monmap --keyring /tmp/ceph.mon.keyring
```

Phân quyền lại thư mục chứ tiến trình
```
chown -R ceph:ceph /var/lib/ceph/mon
chown -R ceph:ceph /var/log/ceph
chown -R ceph:ceph /var/run/ceph
chown -R ceph:ceph /etc/ceph
```

Chạy tiến trình vừa tạo, nó sẽ tự động thêm vào Cluster Ceph (File cấu hình phải được chia sẻ) . Tiến trình cần được gán địa chỉ thông qua:
- File cấu hình (/etc/ceph/ceph.conf)
- Gán trực tiếp

Phương pháp gán trực tiếp, sử dụng tham số `--public-addr {ip:port}`:
```
ceph-mon -i {mon-id} --public-addr {ip:port}

VD:
ceph-mon -i mon-1 --public-addr 192.168.2.154
```

Nếu đã chia sẻ File cấu hình, kích hoạt tiến trình monitor bằng:
```
systemctl start ceph-mon@<monitor_hostname>
systemctl enable ceph-mon@<monitor_hostname>
```


## Loại bỏ tiến trình Monitor
> Có thể remove mon từ node có quyền admin

### Bước 1: As root, stop the monitor
```
systemctl stop ceph-mon@<monitor_hostname>
```

### Bước 2: Xóa monitor nằm trong cluster
```
ceph mon remove <mon_id>
```

### Bước 3: Tạo node chứa tiến trình Monitor, xóa đối tượng monitor khỏi file cấu hình. 
- Loại bỏ cấu hình tại /etc/ceph/ceph.conf

### Bước 4: Đồng bộ các các File cấu hình Ceph trên cụm
```
 scp /etc/ceph/ceph.conf <user>@<target_hostname>:/etc/ceph/
```

### Bước 5: Tùy chọn, Khi cần backup dữ liệu của tiến trình montior xóa
> Backup data mon node remove

```
mv /var/lib/ceph/mon/<cluster>-<daemon_id> /var/lib/ceph/mon/removed-<cluster>-<daemon_id>
```

### Bước 6: Xóa dữ liệu tiến trình monitor :
```
rm -r /var/lib/ceph/mon/<cluster>-<daemon_id>
```

## Tạo mới OSD

### Chuẩn bị: Chuyển cấu hình /etc/ceph/ceph.conf từ node admin
```
scp /etc/ceph/ceph.conf <user>@<target_hostname>:/etc/ceph/
```
> Giữ đồng bộ các file cấu hình Ceph


### Bước 1: Tạo BLUESTORE OSD
#### Lựa chọn 1:
```
ssh {node-name}
sudo ceph-volume lvm create --data {data-path}

VD:
ssh node1
sudo ceph-volume lvm create --data /dev/hdd1
```

#### Lựa chọn 2:
Chuẩn bị OSD.
```
ssh {node-name}
sudo ceph-volume lvm prepare --data {data-path} {data-path}

VD:
ssh node1
sudo ceph-volume lvm prepare --data /dev/hdd1
```

Sau khi đã chuẩn bị, ID và FSID sinh ra của OSD cần thiết cho bước kích hoạt. Thông tin này có thể lấy được từ CMD (trên node chưa OSD):
```
sudo ceph-volume lvm list

```

Kích hoạt OSD:
```
sudo ceph-volume lvm activate {ID} {osd fsid}
VD:
sudo ceph-volume lvm activate 0 a7f64266-0894-4f1e-a635-d0aeaca0e993
```

Chú ý:
Nếu không thể lấy status Ceph -s, kiểm tra status mon server, nếu kích hoạt service nếu service đang stop
```
systemctl status ceph-mon@mon1
systemctl start ceph-mon@mon1
```

## Loại bỏ OSD
### Bước 1: Trước khi xóa OSD khởi cụm, cần tắt tiến trình OSD. Nó sẽ giúp tránh 1 số lỗi không mong muốn:
```
systemctl disable ceph-osd@<osd_id>
systemctl stop ceph-osd@<osd_id>

VD:
# systemctl disable ceph-osd@4
# systemctl stop ceph-osd@4
```

### Bước 2: Xóa OSD khởi storage cluster:
```
ceph osd out <osd_id>

VD:
ceph osd out osd.4
```

### Bước3: Xóa OSD khỏi Cluster Map, từ đó node không còn nhận tiến trình đọc ghi dữ liệu. Xóa OSD khỏi device list:
```
ceph osd crush remove <osd_name>

VD:
ceph osd crush remove osd.4
```

### Bước 4: Xóa khóa chứng thực OSD:
```
ceph auth del osd.<osd_id>

VD:
ceph auth del osd.4
```

### Bước 5: Xóa OSD:
```
ceph osd rm <osd_id>

VD:
ceph osd rm 4
```

### Bước 6: Xóa cấu hình OSD (Nếu có đưa vào file cấu hình ceph.conf):
```
vim /etc/ceph/ceph.conf

```
Remove the OSD entry from the ceph.conf file, if it exists:
```
[osd.4]
host = <hostname>
```

### Bước 7: Loại bỏ OSD mount /etc/fstab (Ổ đĩa)

### Bước 8: Giữa cho file cấu hình `ceph.conf` đồng bộ trên toàn cụm


## NOTE: Lỗi 
### OSD đã tạo từ trước, đã loại bỏ khỏi cụm. Sau đó cần thêm lại vào cụm
```
[root@ceph-node-2 ~]# ceph-volume lvm create --data /dev/sdc1
Running command: /bin/ceph-authtool --gen-print-key
Running command: /bin/ceph --cluster ceph --name client.bootstrap-osd --keyring /var/lib/ceph/bootstrap-osd/ceph.keyring -i - osd new 5da2a8dc-391d-4ea1-9bbf-b3c4cf996933
Running command: vgcreate --force --yes ceph-4a2ad9ea-6136-44e4-a9aa-b63717356fec /dev/sdc1
 stderr: Can't open /dev/sdc1 exclusively.  Mounted filesystem?
--> Was unable to complete a new OSD, will rollback changes
--> OSD will be fully purged from the cluster, because the ID was generated
Running command: ceph osd purge osd.3 --yes-i-really-mean-it
 stderr: purged osd.3
-->  RuntimeError: command returned non-zero exit status: 5
[root@ceph-node-2 ~]# fdisk /dev/sdc
Welcome to fdisk (util-linux 2.23.2).
```

> Sửa: Cần xóa vgs đã tồn tại (xóa OSD đã xóa khỏi cluster trước) rồi pvs sau đó mới có thể chạy câu lênh `ceph-volume lvm create`

## Nguồn

https://access.redhat.com/documentation/en-us/red_hat_ceph_storage/
