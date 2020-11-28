# Hướng dẫn cài đặt Ceph Octopus 3 Node - Offline - CentOS 8 - Ceph Ansible - Git

## Phần 1: Chuẩn bị
Network:
- vlan MNGT: eth0: 10.10.30.0/24
- vlan CephCOM: eth1: 10.10.31.0/24
- vlan CephREP: eth2: 10.10.32.0/24

3 Disk:
- vda: sử dụng để cài OS
- vdb,vdc: sử dụng làm OSD (nơi chứa dữ liệu)

Lưu ý:
- Thực hiện cài đặt trên VM CentOS 8 version 8.2.2004

## Phần 1: Chuẩn bị
Network:
- vlan MNGT: eth0: 10.10.30.0/24
- vlan CephCOM: eth1: 10.10.31.0/24
- vlan CephREP: eth2: 10.10.32.0/24

3 Disk:
- vda: sử dụng để cài OS
- vdb,vdc: sử dụng làm OSD (nơi chứa dữ liệu)

### Ceph01

```
hostnamectl set-hostname ceph01

echo "Setup IP eth0"
nmcli c modify eth0 ipv4.addresses 10.10.30.57/24
nmcli c modify eth0 ipv4.gateway 10.10.30.1
nmcli c modify eth0 ipv4.dns 8.8.8.8
nmcli c modify eth0 ipv4.method manual
nmcli con mod eth0 connection.autoconnect yes

echo "Setup IP eth1"
nmcli c modify eth1 ipv4.addresses 10.10.31.57/24
nmcli c modify eth1 ipv4.method manual
nmcli con mod eth1 connection.autoconnect yes

echo "Setup IP eth2"
nmcli c modify eth2 ipv4.addresses 10.10.32.57/24
nmcli c modify eth2 ipv4.method manual
nmcli con mod eth2 connection.autoconnect yes

sed -i 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/sysconfig/selinux
sed -i 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/selinux/config
systemctl stop firewalld
systemctl disable firewalld

init 6
```

### Ceph02

```
hostnamectl set-hostname ceph02

echo "Setup IP eth0"
nmcli c modify eth0 ipv4.addresses 10.10.30.58/24
nmcli c modify eth0 ipv4.gateway 10.10.30.1
nmcli c modify eth0 ipv4.dns 8.8.8.8
nmcli c modify eth0 ipv4.method manual
nmcli con mod eth0 connection.autoconnect yes

echo "Setup IP eth1"
nmcli c modify eth1 ipv4.addresses 10.10.31.58/24
nmcli c modify eth1 ipv4.method manual
nmcli con mod eth1 connection.autoconnect yes

echo "Setup IP eth2"
nmcli c modify eth2 ipv4.addresses 10.10.32.58/24
nmcli c modify eth2 ipv4.method manual
nmcli con mod eth2 connection.autoconnect yes

sed -i 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/sysconfig/selinux
sed -i 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/selinux/config
systemctl stop firewalld
systemctl disable firewalld

init 6
```

### Ceph03

```
hostnamectl set-hostname ceph03

echo "Setup IP eth0"
nmcli c modify eth0 ipv4.addresses 10.10.30.59/24
nmcli c modify eth0 ipv4.gateway 10.10.30.1
nmcli c modify eth0 ipv4.dns 8.8.8.8
nmcli c modify eth0 ipv4.method manual
nmcli con mod eth0 connection.autoconnect yes

echo "Setup IP eth1"
nmcli c modify eth1 ipv4.addresses 10.10.31.59/24
nmcli c modify eth1 ipv4.method manual
nmcli con mod eth1 connection.autoconnect yes

echo "Setup IP eth2"
nmcli c modify eth2 ipv4.addresses 10.10.32.59/24
nmcli c modify eth2 ipv4.method manual
nmcli con mod eth2 connection.autoconnect yes

sed -i 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/sysconfig/selinux
sed -i 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/selinux/config
systemctl stop firewalld
systemctl disable firewalld

init 6
```

### Cấu hình chỉ định local repo
> Thực hiện trên tất cả các node Ceph

Disable Gateway tới Internet `/etc/sysconfig/network-scripts/ifcfg-eth0`
```
...
#GATEWAY=10.10.30.1
DNS1=8.8.8.8
```

Khởi động lại network
```
ifdown eth0 && ifup eth0
```

Disable tất cả repo hiện có
```
yum clean all
mv /etc/yum.repos.d /etc/yum.repos.d.bak
```

Cấu hình Repo
```
mkdir -p /etc/yum.repos.d

cat <<EOF> /etc/yum.repos.d/CentOS-LocalRepo.repo
[BaseOS]
name=CentOS-\$releasever - Base
baseurl=http://10.10.30.54/centos/\$releasever/BaseOS/\$basearch/os/
gpgcheck=1
enabled=1
gpgkey=http://10.10.30.54/centos/\$releasever/RPM-GPG-KEY-CentOS-Official

[AppStream]
name=CentOS-\$releasever - AppStream
baseurl=http://10.10.30.54/centos/\$releasever/AppStream/\$basearch/os/
gpgcheck=1
enabled=1
gpgkey=http://10.10.30.54/centos/\$releasever/RPM-GPG-KEY-CentOS-Official

[centosplus]
name=CentOS-\$releasever - Plus
baseurl=http://10.10.30.54/centos/\$releasever/centosplus/\$basearch/os/
gpgcheck=1
enabled=0
gpgkey=http://10.10.30.54/centos/\$releasever/RPM-GPG-KEY-CentOS-Official

[extras]
name=CentOS-\$releasever - Extras
baseurl=http://10.10.30.54/centos/\$releasever/extras/\$basearch/os/
gpgcheck=1
enabled=1
gpgkey=http://10.10.30.54/centos/\$releasever/RPM-GPG-KEY-CentOS-Official

[PowerTools]
name=CentOS-\$releasever - PowerTools
baseurl=http://10.10.30.54/centos/\$releasever/PowerTools/\$basearch/os/
gpgcheck=1
enabled=0
gpgkey=http://10.10.30.54/centos/\$releasever/RPM-GPG-KEY-CentOS-Official

[cr]
name=CentOS-\$releasever - cr
baseurl=http://10.10.30.54/centos/\$releasever/cr/\$basearch/os/
gpgcheck=1
enabled=0
gpgkey=http://10.10.30.54/centos/\$releasever/RPM-GPG-KEY-CentOS-Official

[fasttrack]
name=CentOS-\$releasever - fasttrack
baseurl=http://10.10.30.54/centos/\$releasever/fasttrack/\$basearch/os/
gpgcheck=1
enabled=0
gpgkey=http://10.10.30.54/centos/\$releasever/RPM-GPG-KEY-CentOS-Official
EOF
```

Cấu hình sử dụng Local Repo Ceph Mirrors
```
cat <<EOF> /etc/yum.repos.d/ceph.repo
[ceph]
name=Ceph packages for $basearch
baseurl=http://10.10.30.54/ceph/el8/x86_64/
enabled=1
priority=2
gpgcheck=0
gpgkey=http://10.10.30.54/ceph/el8/keys/release.asc

[ceph-noarch]
name=Ceph noarch packages
baseurl=http://10.10.30.54/ceph/el8/noarch
enabled=1
priority=2
gpgcheck=0
gpgkey=http://10.10.30.54/ceph/el8/keys/release.asc

[ceph-source]
name=Ceph source packages
baseurl=http://10.10.30.54/ceph/el8/SRPMS
enabled=0
priority=2
gpgcheck=0
gpgkey=http://10.10.30.54/ceph/el8/keys/release.asc
EOF
```

Cấu hình sử dụng Local Repo EPEL CentOS 8
```
cat <<EOF> /etc/yum.repos.d/CentOS-Epel.repo
[epel]
name=Extra Packages for Enterprise Linux \$releasever - \$basearch
baseurl=http://10.10.30.54/epel/8/x86_64/
enabled=1
gpgcheck=1
gpgkey=http://10.10.30.54/epel/8/x86_64/RPM-GPG-KEY-EPEL-8
EOF
```

Cài đặt EPEL
```
yum -y install epel-release
```

Xóa các Repo EPEL mới sinh ra (Vì đã có local repo)
```
rm -rf /etc/yum.repos.d/epel*
yum clean all
```

Kết quả
```
[root@cephaio ~]# ls /etc/yum.repos.d/
CentOS-Epel.repo  CentOS-LocalRepo.repo  ceph.repo
```

### Cấu hình NTP
> Thực hiện trên tất cả Node Ceph

Cài đặt chrony
```
timedatectl set-timezone Asia/Ho_Chi_Minh
yum -y install chrony
NTP_SERVER_IP='10.10.30.15'
sed -i '/server/d' /etc/chrony.conf
echo "server $NTP_SERVER_IP iburst" >> /etc/chrony.conf
systemctl enable chronyd.service
systemctl restart chronyd.service
chronyc sources
```

Lưu ý:
- Snapshot preceph

## Phần 2: Cài đặt Ceph

### Config trên tất cả các node

Tạo mới user
```
sudo useradd -d /home/cephuser -m cephuser
sudo passwd cephuser
```

Phần quyền sudo
```
echo "cephuser ALL = (root) NOPASSWD:ALL" | sudo tee /etc/sudoers.d/cephuser
sudo chmod 0440 /etc/sudoers.d/cephuser
```

### Cài đặt Ceph thông qua Ceph Ansbile

Lưu ý:
- Thực hiện tại Ceph01

Bổ sung các gói quan trọng
```
yum install gzip tar byobu -y
```

Lưu ý:
- Copy backup Ceph Ansible tới Node Ceph01

Kết quả
```
[root@ceph01 backup-ceph-ansible-octopus]# tree
.
├── 01-ceph-ansible
│   └── stable-5.0.zip
└── 02-pip
    ├── requirements
    │   ├── ansible-2.9.15.tar.gz
    │   ├── cffi-1.14.4-cp36-cp36m-manylinux1_x86_64.whl
    │   ├── cryptography-3.2.1-cp35-abi3-manylinux2010_x86_64.whl
    │   ├── importlib_resources-3.3.0-py2.py3-none-any.whl
    │   ├── Jinja2-2.11.2-py2.py3-none-any.whl
    │   ├── MarkupSafe-1.1.1-cp36-cp36m-manylinux1_x86_64.whl
    │   ├── netaddr-0.8.0-py2.py3-none-any.whl
    │   ├── pycparser-2.20-py2.py3-none-any.whl
    │   ├── PyYAML-5.3.1.tar.gz
    │   ├── six-1.15.0-py2.py3-none-any.whl
    │   └── zipp-3.4.0-py3-none-any.whl
    ├── requirements.txt
    ├── venv
    │   ├── appdirs-1.4.4-py2.py3-none-any.whl
    │   ├── distlib-0.3.1-py2.py3-none-any.whl
    │   ├── filelock-3.0.12-py3-none-any.whl
    │   ├── importlib_metadata-3.1.0-py2.py3-none-any.whl
    │   ├── importlib_resources-3.3.0-py2.py3-none-any.whl
    │   ├── six-1.15.0-py2.py3-none-any.whl
    │   ├── virtualenv-20.2.1-py2.py3-none-any.whl
    │   └── zipp-3.4.0-py3-none-any.whl
    └── virtualenv

5 directories, 21 files
```

Cấu hình ssh-keypair
```
cd
ssh-keygen -t rsa -N "" -f ~/.ssh/id_rsa

cat <<EOF > ~/.ssh/config 
Host 10.10.30.57
   Hostname 10.10.30.57
   User cephuser
Host 10.10.30.58
   Hostname 10.10.30.58
   User cephuser
Host 10.10.30.59
   Hostname 10.10.30.59
   User cephuser
EOF

ssh-copy-id 10.10.30.57
ssh-copy-id 10.10.30.58
ssh-copy-id 10.10.30.59
```

Cài đặt gói python3 và virtualenv
```
cd
yum install -y python3 python3-pip unzip
pip3 install --no-index --find-links=/root/backup-ceph-ansible-octopus/02-pip/venv virtualenv
```

Cài đặt Ceph Ansible từ Git
```
cd /root/backup-ceph-ansible-octopus/01-ceph-ansible/
unzip stable-5.0.zip
mv ceph-ansible-stable-5.0 ceph-ansible
mv ceph-ansible /usr/share/ceph-ansible
```

Cấu hình
```
cd /usr/share/ceph-ansible/
cp group_vars/all.yml.sample group_vars/all.yml
cp group_vars/osds.yml.sample group_vars/osds.yml
cp site.yml.sample site.yml
```

Cấu hình file inventory
```
cat <<EOF > /usr/share/ceph-ansible/inventory_hosts
[mons]
10.10.30.57
10.10.30.58
10.10.30.59

[osds]
10.10.30.57
10.10.30.58
10.10.30.59

[mgrs]
10.10.30.57
EOF
```

Cấu hình Ceph
```
cat <<EOF > group_vars/all.yml
## General
## Cluster
---
dummy:

fetch_directory: fetch/
cluster: ceph

mon_group_name: mons
mgr_group_name: mgrs
osd_group_name: osds
rgw_group_name: rgws
mds_group_name: mdss
nfs_group_name: nfss
rbdmirror_group_name: rbdmirrors
client_group_name: clients
iscsi_gw_group_name: iscsigws
rgwloadbalancer_group_name: rgwloadbalancers

## Firewalld
configure_firewall: false


## Repo
ceph_repository_type: cdn
ceph_origin: repository
ceph_repository: custom
ceph_release_num: 15
ceph_custom_key: http://10.10.30.54/ceph/el8/keys/release.asc
ceph_custom_repo: http://10.10.30.54/ceph/el8

## Custom
ntp_service_enabled: false
monitor_interface: eth1
public_network: 10.10.31.0/24
cluster_network: 10.10.32.0/24
ip_version: ipv4
generate_fsid: true
cephx: true

## Override
ceph_conf_overrides:
  global:
    osd_pool_default_pg_num: 8
    osd_pool_default_size: 2
    osd_pool_default_min_size: 1

## Dashboard - Grafana
dashboard_enabled: false
EOF
```

Cấu hình nhận diện OSD

```
cat << EOF>> group_vars/osds.yml
osd_objectstore: bluestore
devices:
  - /dev/vdb
  - /dev/vdc
EOF
```

Tạo biến môi trường, cài đặt ansible
```
cd /usr/share/ceph-ansible
virtualenv env
source env/bin/activate
pip3 install --no-index --find-links=/root/backup-ceph-ansible-octopus/02-pip/requirements -r /root/backup-ceph-ansible-octopus/02-pip/requirements.txt
```

Cấu hình Ansbile
```
mkdir -p /etc/ansible
cd /etc/ansible
cp ansible.cfg ansible.cfg.bak

cat << EOF > /etc/ansible/ansible.cfg
[defaults]
host_key_checking=False
pipelining=True
forks=100
[inventory]
[privilege_escalation]
[paramiko_connection]
[ssh_connection]
[persistent_connection]
[accelerate]
[selinux]
[colors]
[diff]
EOF
```

Kiểm tra
```
cd /usr/share/ceph-ansible
source env/bin/activate
ansible -m ping -i inventory_hosts all
```

Kết quả
```
(env) [root@ceph01 ceph-ansible]# ansible -m ping -i inventory_hosts all

[WARNING]: log file at /root/ansible/ansible.log is not writeable and we cannot create it, aborting

10.10.30.59 | SUCCESS => {
    "ansible_facts": {
        "discovered_interpreter_python": "/usr/libexec/platform-python"
    },
    "changed": false,
    "ping": "pong"
}
10.10.30.57 | SUCCESS => {
    "ansible_facts": {
        "discovered_interpreter_python": "/usr/libexec/platform-python"
    },
    "changed": false,
    "ping": "pong"
}
10.10.30.58 | SUCCESS => {
    "ansible_facts": {
        "discovered_interpreter_python": "/usr/libexec/platform-python"
    },
    "changed": false,
    "ping": "pong"
}
```

Thực hiện các bước tiếp theo trong byobu
```
byobu
```

Lưu ý

Cài đặt Ceph
```
cd /usr/share/ceph-ansible
source env/bin/activate
ansible-playbook site.yml -v -i inventory_hosts

# Nễu lỗi
ansible-playbook site.yml -vvvv -i inventory_hosts
```

Kiểm tra ceph
```
(env) [root@ceph01 ceph-ansible]# ceph -v
ceph version 15.2.6 (cb8c61a60551b72614257d632a574d420064c17a) octopus (stable)

(env) [root@ceph01 ceph-ansible]# ceph -s
  cluster:
    id:     9ee6309f-5821-46fe-a38a-f67b99e52f0d
    health: HEALTH_OK
 
  services:
    mon: 3 daemons, quorum ceph01,ceph02,ceph03 (age 19h)
    mgr: ceph01(active, since 19h)
    osd: 6 osds: 6 up (since 19h), 6 in (since 19h)
 
  data:
    pools:   1 pools, 1 pgs
    objects: 0 objects, 0 B
    usage:   6.0 GiB used, 114 GiB / 120 GiB avail
    pgs:     1 active+clean 
```
Tới đây đã hoàn thành tài liệu cài Ceph Nautilus bằng Ceph Ansible

## Nguồn

https://docs.ceph.com/projects/ceph-ansible/en/stable-4.0.25/installation/methods.html#custom-repository

https://access.redhat.com/documentation/en-us/red_hat_ceph_storage/4/html/installation_guide/installing-red-hat-ceph-storage-using-ansible

