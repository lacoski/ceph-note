# Hướng dẫn Backup gói Ceph

## Chuẩn bị

Version CentOS 7: 7.9.2009

```
hostnamectl set-hostname cephbackup3056

echo "Setup IP eth0"
nmcli c modify eth0 ipv4.addresses 10.10.30.56/24
nmcli c modify eth0 ipv4.gateway 10.10.30.1
nmcli c modify eth0 ipv4.dns 8.8.8.8
nmcli c modify eth0 ipv4.method manual
nmcli con mod eth0 connection.autoconnect yes

sed -i 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/sysconfig/selinux
sed -i 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/selinux/config
systemctl stop firewalld
systemctl disable firewalld

init 6
```

- snapshot begin

## Phần 1: Backup Ceph Local Repo

```
mkdir -p /root/backup-local-repo
```

### Bước 1: Backup gói Chrony

```
mkdir -p /root/backup-local-repo/01-chrony/
yum install --downloadonly --downloaddir=/root/backup-local-repo/01-chrony/ chrony
yum localinstall -y /root/backup-local-repo/01-chrony/*.rpm
```

### Bước 2: Backup epel

```
mkdir -p /root/backup-local-repo/02-epel/
yum install --downloadonly --downloaddir=/root/backup-local-repo/02-epel/ epel-release
yum localinstall -y /root/backup-local-repo/02-epel/*.rpm
```

### Bước 3: Backup các gói hỗ trợ

```
mkdir -p /root/backup-local-repo/03-extra/
yum install --downloadonly --downloaddir=/root/backup-local-repo/03-extra/ byobu createrepo wget nginx
yum localinstall -y /root/backup-local-repo/03-extra/*.rpm
```

## Phần 2: Backup gói Ceph Ansible

```
mkdir -p /root/backup-ceph-ansible/
```

### Bước 1: Backup gói python, git

```
mkdir -p /root/backup-ceph-ansible/01-environment/
yum install --downloadonly --downloaddir=/root/backup-ceph-ansible/01-environment/ python3 python3-pip byobu git
yum localinstall -y /root/backup-ceph-ansible/01-environment/*.rpm
```

### Bước 2: Backup Ceph Ansible từ Git

```
mkdir -p /root/backup-ceph-ansible/02-ceph-ansible/
cd /root/backup-ceph-ansible/02-ceph-ansible/ && wget https://github.com/ceph/ceph-ansible/archive/stable-4.0.zip
cd
```

### Bước 3: Backup gói pip
> Lưu ý: Lấy nội dung tư requirements.txt của Ceph Ansible

```
mkdir -p /root/backup-ceph-ansible/03-pip/
mkdir -p /root/backup-ceph-ansible/03-pip/virtualenv
mkdir -p /root/backup-ceph-ansible/03-pip/requirements

cd /root/backup-ceph-ansible/03-pip/virtualenv
pip3 download -d /root/backup-ceph-ansible/03-pip/venv virtualenv
pip3 install --no-index --find-links=/root/backup-ceph-ansible/03-pip/venv virtualenv

cd /root/backup-ceph-ansible/03-pip/requirements


cat <<EOF> /root/backup-ceph-ansible/03-pip/requirements.txt
ansible>=2.9,<2.10,!=2.9.10
netaddr
EOF

cd /root/
virtualenv env -p python3
source env/bin/activate
pip3 download -d /root/backup-ceph-ansible/03-pip/requirements -r /root/backup-ceph-ansible/03-pip/requirements.txt
```

## Phần 3: Backup gói Repo Ceph
```
mkdir -p /root/backup-ceph-rpm
```
### Gói RPM Ceph

Tải về các gói Ceph
```
mkdir -p /root/backup-ceph-rpm/repos/{SRPMS,x86_64,noarch}
cd /root/backup-ceph-rpm/repos/SRPMS && wget  -nH --cut-dirs=3 -r --no-parent https://download.ceph.com/rpm-nautilus/el7/SRPMS/
cd /root/backup-ceph-rpm/repos/noarch && wget  -nH --cut-dirs=3 -r --no-parent https://download.ceph.com/rpm-nautilus/el7/noarch/
cd /root/backup-ceph-rpm/repos/x86_64 && wget -r -nH --cut-dirs=3 --no-parent -A '*-14.2.14-0.el7.x86_64.rpm' https://download.ceph.com/rpm-nautilus/el7/x86_64/

mkdir -p /root/backup-ceph-rpm/repos/keys
cd /root/backup-ceph-rpm/repos/keys && wget  -nH --cut-dirs=3 -r --no-parent https://download.ceph.com/keys/
```

Xóa repodata mặc định
```
cd /root/backup-ceph-rpm/repos/x86_64/ && rm -rf repodata index.html
cd /root/backup-ceph-rpm/repos/SRPMS/ && rm -rf repodata index.html
cd /root/backup-ceph-rpm/repos/noarch/ && rm -rf repodata index.html
```

Lọc các packages trong thư mục /root/backup-ceph-rpm/repos/SRPMS/ chỉ giữ lại version 14.2.14
```
rm -rf $(ls /root/backup-ceph-rpm/repos/SRPMS/ -I "ceph-14.2.14-0.el7.src.rpm" | grep ceph-14)
```

Tới đây đã Backup xong toàn bộ gói cần thiết, copy các gói tới node Backup
