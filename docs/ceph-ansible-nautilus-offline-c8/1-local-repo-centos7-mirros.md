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
mkdir -p /var/www/repo
```

Tạo mới file `/etc/centos8_reposync.sh`

```
#!/bin/bash
repos_base_dir="/var/www/repo"

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

vim /etc/nginx/conf.d/centos.conf
server {
        listen   80;
        server_name  10.10.30.54;
        root   /var/www/repos;
        location / {
                index  index.php index.html index.htm;
                autoindex on;   #enable listing of directory index
        }
}

## Nguồn

https://computingforgeeks.com/how-to-create-centos-8-local-repository-mirrors-with-rsync-nginx/