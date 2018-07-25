# Cài đặt Ceph All in one Jewel - CentOS 7
---
## Chuẩn bị

### Về tài nguyên
__Yêu cầu sử dụng 1 node, chạy CentOS 7 64bit__
```
CPU         2 core
RAM         4 GB

Disk        sba: os
            sbd,sdc,sde: 3 disk osd

Network     ens33: 1 replicate data
            ens34: 1 access ceph
```


## Cài đặt
### Phần 1 - Cấu hình chuẩn bị trên node
#### Bước 1: Tạo Ceph User
Tạo Ceph user 'cephuser' trên node.
```
useradd -d /home/cephuser -m cephuser
passwd cephuser
```
Lưu ý:
- User này sẽ được sử dụng bởi `ceph-deploy`. Tức, `ceph-deploy` sẽ sử dụng user này để triển khai các cấu hình của Ceph
- Nếu bỏ qua user này `ceph-deploy` sẽ vẫn chạy, nó sẽ tự động sử dụng biến user môi trường.

Cấp quyền root cho user vừa tạo
```
echo "cephuser ALL = (root) NOPASSWD:ALL" | sudo tee /etc/sudoers.d/cephuser
chmod 0440 /etc/sudoers.d/cephuser
sed -i s'/Defaults requiretty/#Defaults requiretty'/g /etc/sudoers
```
#### Bước 2: Cấu hình NTP
Sử dụng NTP đồng bộ thời gian trên tất cả các Node.
> Ở đây sử dụng NTP pool US.

```
yum install -y ntp ntpdate ntp-doc
ntpdate 0.us.pool.ntp.org
hwclock --systohc
systemctl enable ntpd.service
systemctl start ntpd.service
```

#### Bước 3 (Tùy chọn): Nếu sử dụng VMware, cần sử dụng công cụ hỗ trợ
```
yum install -y open-vm-tools
```

#### Bước 4: Hủy bỏ SELinux
```
sed -i 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/selinux/config
```

#### Bước 5: Cấu hình Host File
```
vim /etc/hosts
```
Nội dung
```
# content vim
192.168.2.100 ceph-aio
```
> Ping thử tới host, kiếm tra Network

### Phần 2: Cấu hình SSH Server
> __Cấu hình trên ceph-aio node__

#### Bước 1: Truy cập ceph-aio
```
ssh root@ceph-aio
```

#### Bước 2: Tạo ssh-key
```
ssh-keygen
```
> Để khoảng trắng trên các lựa chọn


#### Bước 3: Cấu hình ssh file
```
vim ~/.ssh/config
```
Nội dung
```
# content vim

Host ceph-aio
        Hostname ceph-aio
        User cephuser
```
Thay đổi quyền trên file
```
chmod 644 ~/.ssh/config
```

Chuyển ssh-key tới known_hosts
```
ssh-keyscan ceph-aio >> ~/.ssh/known_hosts
ssh-copy-id ceph-aio
```

> Yều cầu nhập passwd trong lần đầu tiền truy cập

### Phần 3: Cấu hình Firewalld
#### Tùy chọn 1: Cấu hình dựa theo lab
Bỏ qua cấu hình firewall
```
systemctl stop firewalld
systemctl disable firewalld
```

#### Tùy chọn 2: Cấu hình firewalld (Chưa kiểm chứng)
##### Xem thêm
[Cài đặt Ceph trên CentOS 7](ceph-install-lab.md)

### Phần 4: Thiết lập Ceph Cluster
> Tại phân này, ta sẽ cài đặt tât cả các thành phần ceph lên 1 node duy nhất.

Bổ sung các gói
```
yum install python-setuptools -y
yum -y install epel-release
yum install python-virtualenv -y

# update os tránh lỗi
yum update -y
```


#### Bước 1: Truy cập ceph-aio node
```
ssh root@<ceph-aio>
```

#### Bước 2: Cấu hình Ceph repo
```
vi /etc/yum.repos.d/ceph.repo
```
Nội dung
```
[Ceph]
name=Ceph packages for $basearch
baseurl=http://download.ceph.com/rpm-luminous/el7/$basearch
enabled=1
gpgcheck=1
type=rpm-md
gpgkey=https://download.ceph.com/keys/release.asc
priority=1

[Ceph-noarch]
name=Ceph noarch packages
baseurl=http://download.ceph.com/rpm-luminous/el7/noarch
enabled=1
gpgcheck=1
type=rpm-md
gpgkey=https://download.ceph.com/keys/release.asc
priority=1

[ceph-source]
name=Ceph source packages
baseurl=http://download.ceph.com/rpm-luminous/el7/SRPMS
enabled=1
gpgcheck=1
type=rpm-md
gpgkey=https://download.ceph.com/keys/release.asc
priority=1
```

Update repo cập nhất repo ceph mới
```
yum update -y
```


#### Bước 3: Cài đặt ceph-deploy tool từ git
Cài git
```
yum install git -y
```
Download Ceph deploy repo
```
git clone https://github.com/ceph/ceph-deploy.git
```
Build `ceph-deploy` từ source
```
cd ceph-deploy/
./bootstrap
```

Tạo câu lệnh nhanh `ceph-deploy`
```
cp virtualenv/bin/ceph-deploy /usr/bin/
```

#### Bước 4: Tạo mới Ceph Cluster config
Tạo cluster directory
```
mkdir cluster
cd cluster/
```

Tạo mới cluster config với 'ceph-deploy' command
```
ceph-deploy new ceph-aio
```

Cấu hình ceph.conf
```
vim ceph.conf
```
Nội dung
```
[global]
fsid = a0a1f71e-3acd-4035-904d-be26171e1e96
mon_initial_members = ceph-aio
mon_host = 192.168.2.100
auth_cluster_required = cephx
auth_service_required = cephx
auth_client_required = cephx

public network = 192.168.2.0/24
cluster network = 10.0.3.0/24
```

#### Bước 5: Cài đặt Ceph trên Ceph AIO
Cài đặt Ceph trên Ceph AIO.
```
ceph-deploy install --release luminous ceph-aio
```

Thiết lập ceph mon
```
ceph-deploy mon create-initial
```

#### Bước 6: Thiết lập OSD
> Sau khi Ceph được cài đặt tới các node, ta cần thêm tiến trình OSD tới cluster.

Liệt kê OSD
```
ceph-deploy disk list ceph-aio
```

Xóa partition tables trên tất cả node với zap option
```
ceph-deploy disk zap ceph-aio /dev/sdb
ceph-deploy disk zap ceph-aio /dev/sdc
ceph-deploy disk zap ceph-aio /dev/sdd
```

Tạo mới OSD
```
ceph-deploy osd create ceph-aio --data /dev/sdb
ceph-deploy osd create ceph-aio --data /dev/sdc
ceph-deploy osd create ceph-aio --data /dev/sdd
```

Kiểm tra tại OSD node
```
[root@ceph-aio cluster]# lsblk
NAME                                                                                                  MAJ:MIN RM  SIZE RO TYPE MOUNTPOINT
fd0                                                                                                     2:0    1    4K  0 disk 
sda                                                                                                     8:0    0   50G  0 disk 
├─sda1                                                                                                  8:1    0  500M  0 part /boot
└─sda2                                                                                                  8:2    0 49.5G  0 part 
  ├─centos-root                                                                                       253:0    0 45.6G  0 lvm  /
  └─centos-swap                                                                                       253:1    0  3.9G  0 lvm  [SWAP]
sdb                                                                                                     8:16   0   20G  0 disk 
└─ceph--0589e5fc--c1e8--4b7c--b373--eee113f49a4e-osd--block--530493fe--a8d3--4f92--bd20--1a0723e913ab 253:2    0   20G  0 lvm  
sdc                                                                                                     8:32   0   20G  0 disk 
└─ceph--2444521c--2a9c--4bb6--90e8--f124428859b3-osd--block--2c088db4--5529--43b9--928c--b19c810cac15 253:3    0   20G  0 lvm  
sdd                                                                                                     8:48   0   20G  0 disk 
└─ceph--586dc0b9--fe6f--46ab--93bb--18293b57b2a3-osd--block--f8f227f0--f488--41f9--837e--bd6c562d65af 253:4    0   20G  0 lvm  
sr0                                                                                                    11:0    1  636M  0 rom  

```

Thiết lập management-key trên node
```
ceph-deploy admin ceph-aio
```

Thiết lập quyền truy cập file
```
sudo chmod 644 /etc/ceph/ceph.client.admin.keyring
```

Triển khai Ceph MGR nodes
```
ceph-deploy mgr create ceph-aio:ceph-mgr-1
```

### Phần 6: Kiểm tra Ceph setup
#### Kiểm tra cluster health
```
[root@ceph-aio cluster]# sudo ceph health
HEALTH_OK
```

#### Kiểm tra cluster status
```
[root@ceph-aio cluster]# sudo ceph -s
  cluster:
    id:     a0a1f71e-3acd-4035-904d-be26171e1e96
    health: HEALTH_OK
 
  services:
    mon: 1 daemons, quorum ceph-aio
    mgr: ceph-mgr-1(active)
    osd: 3 osds: 3 up, 3 in
 
  data:
    pools:   0 pools, 0 pgs
    objects: 0 objects, 0 bytes
    usage:   3077 MB used, 58350 MB / 61428 MB avail
    pgs:     

```

### Phần 7: Active Ceph dashboard
#### Liệt kê các dashbroard hiện có
```
[root@ceph-aio cluster]# ceph mgr dump
{
    "epoch": 29,
    "active_gid": 4118,
    "active_name": "ceph-mgr-1",
    "active_addr": "192.168.2.100:6806/12549",
    "available": true,
    "standbys": [],
    "modules": [
        "balancer",
        "restful",
        "status"
    ],
    "available_modules": [
        "balancer",
        "dashboard", # Enable dashboard
        "influx",
        "localpool",
        "prometheus",
        "restful",
        "selftest",
        "status",
        "zabbix"
    ],
    "services": {}
}
```
#### Kích hoạt module 
```
ceph mgr module enable dashboard
```
#### Kiểm tra lại
```
[root@ceph-aio cluster]# ceph mgr dump
{
    "epoch": 33,
    "active_gid": 4123,
    "active_name": "ceph-mgr-1",
    "active_addr": "192.168.2.100:6806/12549",
    "available": true,
    "standbys": [],
    "modules": [
        "balancer",
        "dashboard",
        "restful",
        "status"
    ],
    "available_modules": [
        "balancer",
        "dashboard",
        "influx",
        "localpool",
        "prometheus",
        "restful",
        "selftest",
        "status",
        "zabbix"
    ],
    "services": {
        "dashboard": "http://ceph-aio:7000/"
    }
}
```

#### Truy cập giao diện
```
http://<ip>:7000/
```

![](images/ceph-aio-lumi-1.png)
