# Cài đặt Ceph Nautilus 3 Node - CentOS 7 - Ceph Ansible - Git

Lưu ý:
- Cài Ceph bằng Ceph ansbile qua yum repo đang bị lỗi (đang tìm cách fix)
- Lỗi khi thêm OSD vào cluster Ceph

## Phần 1: Chuẩn bị
Network:
- vlan MNGT: eth0: 10.10.11.0/24
- vlan CephCOM: eth1: 10.10.12.0/24
- vlan CephREP: eth2: 10.10.14.0/24

4 Disk:
- vda: sử dụng để cài OS
- vdb,vdc,vdd: sử dụng làm OSD (nơi chứa dữ liệu)

### Ceph01

```
hostnamectl set-hostname ceph01

echo "Setup IP eth0"
nmcli c modify eth0 ipv4.addresses 10.10.11.87/24
nmcli c modify eth0 ipv4.gateway 10.10.11.1
nmcli c modify eth0 ipv4.dns 8.8.8.8
nmcli c modify eth0 ipv4.method manual
nmcli con mod eth0 connection.autoconnect yes

echo "Setup IP eth1"
nmcli c modify eth1 ipv4.addresses 10.10.12.87/24
nmcli c modify eth1 ipv4.method manual
nmcli con mod eth1 connection.autoconnect yes

echo "Setup IP eth2"
nmcli c modify eth2 ipv4.addresses 10.10.14.87/24
nmcli c modify eth2 ipv4.method manual
nmcli con mod eth2 connection.autoconnect yes

sed -i 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/sysconfig/selinux
sed -i 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/selinux/config
systemctl stop firewalld
systemctl disable firewalld

curl -Lso- https://raw.githubusercontent.com/nhanhoadocs/scripts/master/Utilities/cmdlog.sh | bash

timedatectl set-timezone Asia/Ho_Chi_Minh
yum -y install chrony
systemctl enable chronyd.service
systemctl restart chronyd.service
chronyc sources
```

### Ceph02

```
hostnamectl set-hostname ceph02

echo "Setup IP eth0"
nmcli c modify eth0 ipv4.addresses 10.10.11.88/24
nmcli c modify eth0 ipv4.gateway 10.10.11.1
nmcli c modify eth0 ipv4.dns 8.8.8.8
nmcli c modify eth0 ipv4.method manual
nmcli con mod eth0 connection.autoconnect yes

echo "Setup IP eth1"
nmcli c modify eth1 ipv4.addresses 10.10.12.88/24
nmcli c modify eth1 ipv4.method manual
nmcli con mod eth1 connection.autoconnect yes

echo "Setup IP eth2"
nmcli c modify eth2 ipv4.addresses 10.10.14.88/24
nmcli c modify eth2 ipv4.method manual
nmcli con mod eth2 connection.autoconnect yes

sed -i 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/sysconfig/selinux
sed -i 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/selinux/config
systemctl stop firewalld
systemctl disable firewalld

curl -Lso- https://raw.githubusercontent.com/nhanhoadocs/scripts/master/Utilities/cmdlog.sh | bash

timedatectl set-timezone Asia/Ho_Chi_Minh
yum -y install chrony
systemctl enable chronyd.service
systemctl restart chronyd.service
chronyc sources

init 6
```

### Ceph03

```
hostnamectl set-hostname ceph03

echo "Setup IP eth0"
nmcli c modify eth0 ipv4.addresses 10.10.11.89/24
nmcli c modify eth0 ipv4.gateway 10.10.11.1
nmcli c modify eth0 ipv4.dns 8.8.8.8
nmcli c modify eth0 ipv4.method manual
nmcli con mod eth0 connection.autoconnect yes

echo "Setup IP eth1"
nmcli c modify eth1 ipv4.addresses 10.10.12.89/24
nmcli c modify eth1 ipv4.method manual
nmcli con mod eth1 connection.autoconnect yes

echo "Setup IP eth2"
nmcli c modify eth2 ipv4.addresses 10.10.14.89/24
nmcli c modify eth2 ipv4.method manual
nmcli con mod eth2 connection.autoconnect yes

sed -i 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/sysconfig/selinux
sed -i 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/selinux/config
systemctl stop firewalld
systemctl disable firewalld

curl -Lso- https://raw.githubusercontent.com/nhanhoadocs/scripts/master/Utilities/cmdlog.sh | bash

timedatectl set-timezone Asia/Ho_Chi_Minh
yum -y install chrony
systemctl enable chronyd.service
systemctl restart chronyd.service
chronyc sources

init 6
```

## Phần 2: Cài đặt Ceph

### Config tại tất cả các node

```
sudo useradd -d /home/cephuser -m cephuser
sudo passwd cephuser
echo "cephuser ALL = (root) NOPASSWD:ALL" | sudo tee /etc/sudoers.d/cephuser
sudo chmod 0440 /etc/sudoers.d/cephuser
```

### Cài đặt Ceph thông qua Ceph Ansbile

Lưu ý:
- stable-4.0 Supports Ceph version nautilus. This branch requires Ansible version 2.8.

Lưu ý:
- Thực hiện trên Ceph01

Lưu ý:
- stable-4.0 Supports Ceph version nautilus. This branch requires Ansible version 2.8.

Cài đặt cài ansible, repo Ceph và Ceph Ansible
```
sudo yum install ansible -y 
yum -y install epel-release centos-release-ceph-nautilus
yum -y install ceph-ansible byobu
```

Cấu hình ssh-keypair
```
ssh-keygen -t rsa -N "" -f ~/.ssh/id_rsa

cat <<EOF > ~/.ssh/config 
Host 10.10.11.87
   Hostname 10.10.11.87
   User cephuser
Host 10.10.11.88
   Hostname 10.10.11.88
   User cephuser
Host 10.10.11.89
   Hostname 10.10.11.89
   User cephuser
EOF

ssh-copy-id 10.10.11.87
ssh-copy-id 10.10.11.88
ssh-copy-id 10.10.11.89
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
10.10.11.87
10.10.11.88
10.10.11.89

[osds]
10.10.11.87
10.10.11.88
10.10.11.89

[mgrs]
10.10.11.87

[grafana-server]
10.10.11.88
EOF
```

Cấu hình Ceph
```
cat <<EOF > group_vars/all.yml
## General
## ------- Cluster
---
dummy:

fetch_directory: fetch/
cluster: ceph

mon_group_name: mons
mgr_group_name: mgrs
osd_group_name: osds
grafana_server_group_name: grafana-server
rgw_group_name: rgws
mds_group_name: mdss
nfs_group_name: nfss
rbdmirror_group_name: rbdmirrors
client_group_name: clients
iscsi_gw_group_name: iscsigws
rgwloadbalancer_group_name: rgwloadbalancers

## ------- Firewalld
#configure_firewall: True
#ceph_mon_firewall_zone: public
#ceph_mgr_firewall_zone: public
#ceph_osd_firewall_zone: public
#ceph_rgw_firewall_zone: public
#ceph_mds_firewall_zone: public
#ceph_nfs_firewall_zone: public
#ceph_rbdmirror_firewall_zone: public
#ceph_iscsi_firewall_zone: public
#ceph_dashboard_firewall_zone: public
#ceph_rgwloadbalancer_firewall_zone: public

## Packages

## Install
ceph_repository_type: cdn
ceph_origin: repository
ceph_repository: community
ceph_stable_release: nautilus
monitor_interface: eth1
public_network: 10.10.12.0/24
cluster_network: 10.10.14.0/24
ip_version: ipv4
generate_fsid: true
cephx: true

## Config override
ceph_conf_overrides:
  global:
    osd_pool_default_pg_num: 8
    osd_pool_default_size: 2
    osd_pool_default_min_size: 1

## Dashboard - Grafana
dashboard_enabled: True
dashboard_protocol: http
dashboard_port: 8443
dashboard_admin_user: admin
dashboard_admin_password: Cloud3652020
grafana_admin_user: admin
grafana_admin_password: Cloud3652020

EOF
```

Cấu hình nhận diện OSD
```
cat << EOF>> group_vars/osds.yml
osd_objectstore: bluestore
devices:
  - /dev/vdb
  - /dev/vdc
  - /dev/vdd
EOF
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
ansible -m ping -i inventory_hosts all 
```

Kết quả
```
[root@ceph01 ceph-ansible]# ansible -m ping -i inventory_hosts all 
[WARNING]: Invalid characters were found in group names but not replaced, use -vvvv to see details
10.10.11.88 | SUCCESS => {
    "ansible_facts": {
        "discovered_interpreter_python": "/usr/bin/python"
    }, 
    "changed": false, 
    "ping": "pong"
}
10.10.11.89 | SUCCESS => {
    "ansible_facts": {
        "discovered_interpreter_python": "/usr/bin/python"
    }, 
    "changed": false, 
    "ping": "pong"
}
10.10.11.87 | SUCCESS => {
    "ansible_facts": {
        "discovered_interpreter_python": "/usr/bin/python"
    }, 
    "changed": false, 
    "ping": "pong"
}
```

Bật byobu
```
byobu
```

Cài Ceph thông qua Ceph Ansible
```
cd /usr/share/ceph-ansible
ansible-playbook site.yml -vvvv -i inventory_hosts
```

