# Cài đặt Ceph thủ công
---
## Tổng quan
Áp dụng cho việc phát triển script, các công cụ quản trị từ xa (SaltStack, ansiable chef, juju)

## Kiến trúc triển khai
![](https://github.com/lacoski/khoa-luan/raw/master/Ceph/PIC/ceph-lumi-lab-7.png)

## Chuẩn bị
### Bước 1: Cấu hình hostname trên từng máy
```
hostnamectl set-hostname <node name>
```

## Phần 1: Cài đặt Ceph
> Thực hiện trên tất cả các node triển khai Ceph (các tool triển khai ceph hỗ trợ điều này)

### Bước 1: Cài đăt gói mở rộng yum
> Là mở rộng của YUM, cho phép tạo độ ưu tiên khác nhau trên các kho lưu trữ. Các gói có độ ưu tiên thấp không thể thay thể các gói có độ ưu tiên cao khi cài, kể cả có phiên bản gói độ ưu tiên thập có mới hơn.

```
yum install yum-plugin-priorities -y
```
### Bước 2: Cài đặt release.asc key
```
sudo rpm --import 'https://download.ceph.com/keys/release.asc'
```
### Bước 3: Chỉnh sửa độ ưu tiên Ceph repo (bản luminous)
```
vi /etc/yum.repos.d/ceph.repo
```
Nội dung
```
[ceph]
name=Ceph packages for $basearch
baseurl=https://download.ceph.com/rpm-luminous/el7/$basearch
enabled=1
priority=2
gpgcheck=1
gpgkey=https://download.ceph.com/keys/release.asc

[ceph-noarch]
name=Ceph noarch packages
baseurl=https://download.ceph.com/rpm-luminous/el7/noarch
enabled=1
priority=2
gpgcheck=1
gpgkey=https://download.ceph.com/keys/release.asc

[ceph-source]
name=Ceph source packages
baseurl=https://download.ceph.com/rpm-luminous/el7/SRPMS
enabled=0
priority=2
gpgcheck=1
gpgkey=https://download.ceph.com/keys/release.asc
```
### Bước 4: Cài đặt các gói cơ bản (yêu cầu)
```
yum install snappy leveldb gdisk python-argparse gperftools-libs -y

yum install -y yum-utils && sudo yum-config-manager --add-repo https://dl.fedoraproject.org/pub/epel/7/x86_64/ && sudo yum install --nogpgcheck -y epel-release && sudo rpm --import /etc/pki/rpm-gpg/RPM-GPG-KEY-EPEL-7 && sudo rm /etc/yum.repos.d/dl.fedoraproject.org*

yum update -y
```

### Bước 5: Cài đặt Ceph
```
sudo yum install ceph -y
```

> Sau khi cài Ceph, file config mặc định là `/etc/ceph/ceph.conf`, ceph cũng là tên mặc định của cluster name.


## Phần 2: Cấu hình Setup firewall, SELinux
### Tùy chọn 1: Firewalld, tắt SELinux
```
systemctl stop firewalld
systemctl disable firewalld
setenforce 0
sed -i 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/selinux/config
```
### Tùy chọn 2: Cấu hình firewall
Các port cần chú ý:
- Node Monitor, tiến trình sử dụng port 6789
- Node OSD, tiến trình sử dụng khoảng 6800-7300 (phục vụ cho kết nối nội bộ và truy cập từ bên ngoài)
- Node Ceph Manager (ceph-mgr), tiến trình sử dụng sử dụng port trong khoảng khoảng 6800-7300. Có thể đặt Cephmgr chung với các node monitor.
- Ceph Metadata Server node (ceph-mds) sử dụng port 6800
- Ceph Object Gateway Nodes sử dụng port 7480 mặc định. Có thể sửa port mặc đinh, VD: port 80


## Phần 3: Khởi tạo MONITOR BOOTSTRAPPING
> Trên tất cả các node
### Bước 1: Truy cập node Monitor
```
ssd root@<monitor-node>
```
### Bước 2: Khởi tạo file cấu hình
> File cấu hình /etc/ceph/ceph.conf

Truy cập file cấu hình
```
vim /etc/ceph/ceph.conf
```

- Sinh unique, thêm vào file cấu hình

> Sinh UUID bằng cmd: `uuidgen`

```
fsid = {UUID}

VD:
fsid = a7f64266-0894-4f1e-a635-d0aeaca0e993
```

- Thêm các node chạy tiến trình monitor vào file cấu hình Ceph configuration file.

```
mon initial members = {hostname}[,{hostname}]

VD:
mon initial members = node1 # Chú ý tên này
```

> Chú ý tên mon node phải trùng với mon node khi tạo (nếu không sẽ không thể show được ceph status)

- Thêm địa chỉ IP của các node chạy tiến trình monitor vào Ceph configuration file.

```
mon host = {ip-address}[,{ip-address}]

VD:
mon host = 192.168.0.1 # chú ý ip này
```

### Bước 3: Tạo khóa chia sẻ, sinh khóa bí mật cho monitor node.
```
ceph-authtool --create-keyring /tmp/ceph.mon.keyring --gen-key -n mon. --cap mon 'allow *'
```

### Bước 4: Sinh khóa quản trị, khóa client.admin
```
sudo ceph-authtool --create-keyring /etc/ceph/ceph.client.admin.keyring --gen-key -n client.admin --set-uid=0 --cap mon 'allow *' --cap osd 'allow *' --cap mds 'allow *' --cap mgr 'allow *'
```

### Bước 5: Sinh khóa bootstrap-osd keyring, Sinh khóa client.bootstrap-osd user and add the user to the keyring.
```
sudo ceph-authtool --create-keyring /var/lib/ceph/bootstrap-osd/ceph.keyring --gen-key -n client.bootstrap-osd --cap mon 'profile bootstrap-osd'
```

### Bước 6: Thêm khóa ceph.mon.keyring.
```
sudo ceph-authtool /tmp/ceph.mon.keyring --import-keyring /etc/ceph/ceph.client.admin.keyring
sudo ceph-authtool /tmp/ceph.mon.keyring --import-keyring /var/lib/ceph/bootstrap-osd/ceph.keyring
```


### Bước 7: Generate a monitor map using the hostname(s), host IP address(es) and the FSID. Save it as /tmp/monmap:
```
monmaptool --create --add {hostname} {ip-address} --fsid {uuid} /tmp/monmap

VD:
monmaptool --create --add node1 192.168.0.1 --fsid a7f64266-0894-4f1e-a635-d0aeaca0e993 /tmp/monmap
```
> Chú ý tên hostname (phải cùng tên trong Ceph.conf, chú ý cả ip address)

Sau bước này cần chỉnh sửa lại quyền 2 file chứa khóa:
- /tmp/monmap
- /tmp/ceph.mon.keyring
- Thư mục chứ mon service

```
cd /tmp
chown -R ceph:ceph ceph.mon.keyring
chown -R ceph:ceph monmap
```

### Bước 8: Tạo data directory (or directories) trên monitor host(s).
```
sudo mkdir /var/lib/ceph/mon/{cluster-name}-{hostname}

VD:
mkdir /var/lib/ceph/mon/ceph-node1
chown -R ceph:ceph /var/lib/ceph/mon/ceph-node1
```

### Bước 9: Tạo monitor daemon(s) với monitor map và keyring
```
sudo -u ceph ceph-mon [--cluster {cluster-name}] --mkfs -i {hostname} --monmap /tmp/monmap --keyring /tmp/ceph.mon.keyring

VD:
sudo -u ceph ceph-mon --mkfs -i node1 --monmap /tmp/monmap --keyring /tmp/ceph.mon.keyring
```

### Bước 10: Cấu hình cơ bản cần có trong Ceph Cluster config
```
[global]
fsid = {cluster-id}
mon initial members = {hostname}[, {hostname}]
mon host = {ip-address}[, {ip-address}]
public network = {network}[, {network}]
cluster network = {network}[, {network}]
auth cluster required = cephx
auth service required = cephx
auth client required = cephx
osd journal size = {n}
osd pool default size = {n}  # Write an object n times.
osd pool default min size = {n} # Allow writing n copies in a degraded state.
osd pool default pg num = {n}
osd pool default pgp num = {n}
osd crush chooseleaf type = {n}

VD:
[global]
fsid = cf9343ab-1662-43b6-9fcb-82588a0c8f23
mon initial members = mon1
mon host =  192.168.2.151

public network = 192.168.2.0/24
cluster network = 192.168.3.0/24
auth cluster required = cephx
auth service required = cephx
auth client required = cephx

osd journal size = 1024
osd pool default size = 3
osd pool default min size = 2
osd pool default pg num = 333
osd pool default pgp num = 333
osd crush chooseleaf type = 1
```

### Bước 11: Chạy tiếm trình monitor(s)
Touch the done file.
> Mark that the monitor is created and ready to be started:

```
sudo touch /var/lib/ceph/mon/ceph-node1/done
sudo touch /var/lib/ceph/mon/ceph-node1/upstart
```

Chuẩn bị, chỉnh sử quyền trên các thư mục
```
chown -R ceph:ceph /var/lib/ceph/mon
chown -R ceph:ceph /var/log/ceph
chown -R ceph:ceph /var/run/ceph
chown -R ceph:ceph /etc/ceph
```

Chạy tiếm trình monitor(s).
```
sudo systemctl start ceph-mon@node1
sudo systemctl enable ceph-mon@node1
sudo systemctl status ceph-mon@node1
```

Kiếm tra lại node monitor đang chạy
```
[root@ceph-admin mgr]# ceph -s
  cluster:
    id:     cf9343ab-1662-43b6-9fcb-82588a0c8f23
    health: HEALTH_OK

  services:
    mon: 1 daemons, quorum mon1 # Tiến trình monitor
    mgr: mgr-1(active)
    osd: 0 osds: 0 up, 0 in

  data:
    pools:   0 pools, 0 pgs
    objects: 0 objects, 0 bytes
    usage:   0 kB used, 0 kB / 0 kB avail
    pgs:     
```

## Phần 4: Tạo MANAGER DAEMON CONFIGURATION - MGR
> Trên node Ceph Admin

Tạo khóa chứng thực cho tiến trình:
```
ceph auth get-or-create mgr.$name mon 'allow profile mgr' osd 'allow *' mds 'allow *'

VD:
ceph auth get-or-create mgr.mgr-1 mon 'allow profile mgr' osd 'allow *' mds 'allow *'
```

Chuyển key vừa sinh tới thư mục `/var/lib/ceph/mgr/ceph-mgr-1`
```
mkdir -p /var/lib/ceph/mgr/ceph-mgr-1/
touch /var/lib/ceph/mgr/ceph-mgr-1/keyring
vi /var/lib/ceph/mgr/ceph-mgr-1/keyring
```
Nội dung
```
[mgr.mgr-1]
	key = AQDI4i9bGZXaHRAA6EYM/UAKChfRlBb3qyOHYA==
```

Chạy tiến trình ceph-mgr:
```
# Bằng Ceph
ceph-mgr -i $name

# Trên service
systemctl start ceph-mgr@mgr-1
systemctl status ceph-mgr@mgr-1
systemctl enable ceph-mgr@mgr-1
```

Kiểm tra trạng thái
```
[root@ceph-admin mgr]# ceph -s
  cluster:
    id:     cf9343ab-1662-43b6-9fcb-82588a0c8f23
    health: HEALTH_OK

  services:
    mon: 1 daemons, quorum mon1
    mgr: mgr-1(active) # mgr vừa tạo
    osd: 0 osds: 0 up, 0 in

  data:
    pools:   0 pools, 0 pgs
    objects: 0 objects, 0 bytes
    usage:   0 kB used, 0 kB / 0 kB avail
    pgs:     
```
> Nếu lỗi check thư mục `/var/log/ceph/<tiến trình vừa tạo>.log`
## Phần 5: Thêm OSD node
> Trên node OSD

> Cần tạo tạo Partition trên ổ địa (fdisk /dev/...)

> Các node OSD cần được chia sẻ key từ node admin (/var/lib/ceph/bootstrap-osd/ceph.keyring)

```
scp /var/lib/ceph/bootstrap-osd/ceph.keyring root@<node>:/var/lib/ceph/bootstrap-osd/ceph.keyring
```

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


## Vấn đề
Nếu Node Mon chết, trong thời gian node mon chết có sự kiện sảy ra OSD (lỗi, chết) => không update trạng theo Ceph status (ceph -s)

## Nguồn
http://docs.ceph.com/docs/jewel/install/
