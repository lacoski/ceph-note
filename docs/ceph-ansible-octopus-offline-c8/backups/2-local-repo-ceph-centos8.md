# Hướng dẫn triển khai Local Repo Mirros CentOS 8

## Lưu ý

- Mục tiêu các Repo cần thiết của CentOS mục tiêu cài Ceph hoàn toàn tự local
- Tài liệu sẽ hướng dẫn triển khai local repo gồm: Base và Epel Mirrors CentOS7

## Chuẩn bị

```
hostnamectl set-hostname cepocent8

echo "Setup IP eth0"
nmcli c modify eth0 ipv4.addresses 10.10.30.54/24
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

## Bước 1: Cài đặt gói cần thiết
```
yum -y install nginx
yum -y install tmux rsync
```

Khởi động nginx
```
systemctl start nginx
systemctl enable nginx
systemctl status nginx
```

## Bước 2: Tạo Repo CentOS 8

```
mkdir -p /var/www/repo/centos/8/
```

Tạo mới file `/etc/centos8_reposync.sh`

```
#!/bin/bash
repos_base_dir="/var/www/repo/centos/8/"

# Start sync if base repo directory exist
if [[ -d "$repos_base_dir" ]] ; then
  # Start Sync
  rsync  -avSHP --delete --progress --exclude 'isos' rsync://mirrors.bfsu.edu.cn/centos/8.2.2004/ "$repos_base_dir"
  # Download CentOS 8 repository key
  wget -P $repos_base_dir wget https://www.centos.org/keys/RPM-GPG-KEY-CentOS-Official
fi
```

```
sudo chmod +x /etc/centos8_reposync.sh
```

```
tmux
bash -x /etc/centos8_reposync.sh

sudo /etc/centos8_reposync.sh
```

Lưu ý:
```
# start terminal
tmux

# Re actach
tmux a

# Out: ctrl b + d
```

chmod -R 755 /var/www/repo/

vim /etc/nginx/conf.d/centos.conf
server {
        listen   80;
        server_name  10.10.30.54;
        root   /var/www/repo;
        location / {
                index  index.php index.html index.htm;
                autoindex on;   #enable listing of directory index
        }
}

nginx -s reload

## Config local repo

yum clean all
mv /etc/yum.repos.d /etc/yum.repos.d.bak

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

Cấu hình Repo Ceph CentOS 8
```
cat <<EOF> /etc/yum.repos.d/ceph.repo
[ceph]
name=Ceph packages for $basearch
baseurl=http://10.10.30.54/x86_64/
enabled=1
priority=2
gpgcheck=0
gpgkey=http://10.10.30.54/keys/release.asc

[ceph-noarch]
name=Ceph noarch packages
baseurl=http://10.10.30.54/noarch
enabled=1
priority=2
gpgcheck=0
gpgkey=http://10.10.30.54/keys/release.asc

[ceph-source]
name=Ceph source packages
baseurl=http://10.10.30.54/SRPMS
enabled=0
priority=2
gpgcheck=0
gpgkey=http://10.10.30.54/keys/release.asc
EOF
```


## Nguồn

https://computingforgeeks.com/how-to-create-centos-8-local-repository-mirrors-with-rsync-nginx/

https://www.tecmint.com/fix-failed-to-set-locale-defaulting-to-c-utf-8-in-centos/