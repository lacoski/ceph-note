# Cài đặt Ceph Nautilus 3 Node - Offline - CentOS 7 - Ceph Ansible - Git

## Phần 1: Chuẩn bị
Network:
- vlan MNGT: eth0: 10.10.30.0/24
- vlan CephCOM: eth1: 10.10.31.0/24
- vlan CephREP: eth2: 10.10.32.0/24

3 Disk:
- vda: sử dụng để cài OS
- vdb,vdc: sử dụng làm OSD (nơi chứa dữ liệu)


Copy thư mục `backup-local-repo/01-chrony` tới tất cả các node
Copy thư mục `backup-ceph-ansible` tới ceph01

Kết quả
```
[root@ceph01 ~]# ll
total 12
drwxr-xr-x  2 root root 4096 14:54 25 Th11 01-chrony
-rw-------. 1 root root 1468 18:10 24 Th11 anaconda-ks.cfg
drwxr-xr-x  5 root root 4096 10:21 25 Th11 backup-ceph-ansible

[root@ceph02 ~]# ll
total 12
drwxr-xr-x  2 root root 4096 14:54 25 Th11 01-chrony

[root@ceph03 ~]# ll
total 12
drwxr-xr-x  2 root root 4096 14:54 25 Th11 01-chrony
```


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

Cài đặt chrony
```
yum localinstall -y /root/01-chrony/*.rpm
NTP_SERVER_IP='10.10.30.15'
sed -i '/server/d' /etc/chrony.conf
echo "server $NTP_SERVER_IP iburst" >> /etc/chrony.conf
systemctl enable chronyd.service
systemctl restart chronyd.service
chronyc sources
```

Disable gateway

Lưu ý:
- Snapshot preceph

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

Cài đặt chrony
```
yum localinstall -y /root/01-chrony/*.rpm
NTP_SERVER_IP='10.10.30.15'
sed -i '/server/d' /etc/chrony.conf
echo "server $NTP_SERVER_IP iburst" >> /etc/chrony.conf
systemctl enable chronyd.service
systemctl restart chronyd.service
chronyc sources
```

Lưu ý:
- Disable gateway ra internet
- Snapshot preceph

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

Cài đặt chrony
```
yum localinstall -y /root/01-chrony/*.rpm
NTP_SERVER_IP='10.10.30.15'
sed -i '/server/d' /etc/chrony.conf
echo "server $NTP_SERVER_IP iburst" >> /etc/chrony.conf
systemctl enable chronyd.service
systemctl restart chronyd.service
chronyc sources
```

Lưu ý:
- Disable gateway ra internet
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

### Setup local repo tại tất cả các node

Disable tất cả repo hiện có
```
yum clean all
mv /etc/yum.repos.d /etc/yum.repos.d.bak
```

```
mkdir -p /etc/yum.repos.d
cat <<EOF> /etc/yum.repos.d/ceph.repo
[ceph]
name=Ceph packages for $basearch
baseurl=http://10.10.30.56/x86_64/
enabled=1
priority=2
gpgcheck=0
gpgkey=http://10.10.30.56/keys/release.asc

[ceph-noarch]
name=Ceph noarch packages
baseurl=http://10.10.30.56/noarch
enabled=1
priority=2
gpgcheck=0
gpgkey=http://10.10.30.56/keys/release.asc

[ceph-source]
name=Ceph source packages
baseurl=http://10.10.30.56/SRPMS
enabled=0
priority=2
gpgcheck=0
gpgkey=http://10.10.30.56/keys/release.asc
EOF
```

### Cài đặt Ceph thông qua Ceph Ansbile

Lưu ý:
- Thực hiện tại Ceph01

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

Cài đặt gói
```
yum install -y python3 python3-pip byobu
yum install git -y
pip3 install virtualenv
```

Cài đặt Ceph Ansible từ Git
```
git clone https://github.com/ceph/ceph-ansible.git
cd ceph-ansible
git checkout stable-4.0
cd ..
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
ceph_release_num: 14
ceph_custom_key: http://10.10.30.56/keys/release.asc
ceph_custom_repo: http://10.10.30.56/

## Disable install dependencies Ceph
centos_package_dependencies: []

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
pip3 install -r requirements.txt
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
[root@ceph01 ceph-ansible]# ansible -m ping -i inventory_hosts all 
10.10.30.58 | SUCCESS => {
    "changed": false,
    "ping": "pong"
}
10.10.30.59 | SUCCESS => {
    "changed": false,
    "ping": "pong"
}
10.10.30.57 | SUCCESS => {
    "changed": false,
    "ping": "pong"
}
```

Thực hiện các bước tiếp theo trong byobu
```
byobu
```

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
ceph version 14.2.14 (7e94c5afc28f3eaf36151ad1e1457de5f16c4fdf) nautilus (stable)


(env) [root@ceph01 ceph-ansible]# ceph -s
  cluster:
    id:     97179f61-91cf-4468-8caf-b4adbd37ba02
    health: HEALTH_OK
 
  services:
    mon: 3 daemons, quorum ceph01,ceph02,ceph03 (age 19m)
    mgr: ceph01(active, since 10m)
    osd: 9 osds: 9 up (since 15m), 9 in (since 15m)
 
  data:
    pools:   0 pools, 0 pgs
    objects: 0 objects, 0 B
    usage:   9.0 GiB used, 441 GiB / 450 GiB avail
    pgs:      
```

Tới đây đã hoàn thành tài liệu cài Ceph Nautilus bằng Ceph Ansible

Kiểm tra
```
(env) [root@ceph01 ceph-ansible]# ceph mgr services

{
    "dashboard": "http://ceph01:8443/",
    "prometheus": "http://ceph01:9283/"
}
```

Kiểm tra Ceph Dashboard:
- http://10.10.31.57:8443/#/login?returnUrl=%2Fdashboard - admin / Cloud3652020

Login Grafana:
- http://10.10.31.58:3000/login?redirect=%2F - admin / Cloud3652020


## Nguồn

https://docs.ceph.com/projects/ceph-ansible/en/stable-4.0.25/installation/methods.html#custom-repository

https://github.com/uncelvel/tutorial-ceph/blob/master/docs/setup/ceph-ansible-nautilus-gitsource.md

https://docs.ceph.com/projects/ceph-ansible/en/latest/

https://www.marksei.com/how-to-install-ceph-with-ceph-ansible/

https://access.redhat.com/documentation/en-us/red_hat_ceph_storage/4/html/installation_guide/installing-red-hat-ceph-storage-using-ansible

