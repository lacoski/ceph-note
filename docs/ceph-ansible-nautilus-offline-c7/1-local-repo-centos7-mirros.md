# Hướng dẫn triển khai Local Repo Mirros CentOS 7

## Lưu ý

- Mục tiêu các Repo cần thiết của CentOS mục tiêu cài Ceph hoàn toàn tự local
- Tài liệu sẽ hướng dẫn triển khai local repo gồm: Base và Epel Mirrors CentOS7

## Bước 1: Chuẩn bị môi trường
```
yum install epel-release -y
yum install yum-utils wget -y
yum install byobu -y
```
## Bước 2: Cài đặt Nginx
```
yum install nginx -y
```

Khởi động nginx
```
systemctl start nginx
systemctl enable nginx
systemctl status nginx
```

## Bước 3: Tạo Repo CentOS 7
```
mkdir -p /var/www/html/repos/centos/7/
rsync -avz --delete --progress --exclude 'isos' rsync://mirrors.bfsu.edu.cn/centos/7/ /var/www/html/repos/centos/7/
chmod -R 755 /var/www/html/repos


mkdir -p /var/www/html/repos/epel/7/x86_64
rsync -avz --delete --progress rsync://mirrors.bfsu.edu.cn/epel/7/x86_64/ /var/www/html/repos/epel/7/x86_64
rsync -avz --delete --progress rsync://mirrors.bfsu.edu.cn/epel/RPM-GPG-KEY-EPEL-7 /var/www/html/repos/epel/7/x86_64
chmod -R 755 /var/www/html/repos
```

## Bước 4: Cấu hình Nginx

```
cat << EOF >> /etc/nginx/conf.d/repos.conf
server {
        listen   80;
        server_name  10.10.30.56;
        root   /var/www/html/repos;
        location / {
                index  index.php index.html index.htm;
                autoindex on;   #enable listing of directory index
        }
}
EOF
```

Khởi động lại Nginx
```
nginx -s reload
```

Kiểm tra, truy cập http://10.10.30.56/

## Cấu hình CentOS 7 dùng local repo

```
yum clean all
mv /etc/yum.repos.d /etc/yum.repos.d.bak

mkdir -p /etc/yum.repos.d

cat <<EOF> /etc/yum.repos.d/CentOS-Base.repo
[base]
name=CentOS-$releasever - Base
baseurl=http://10.10.30.56/centos/\$releasever/os/\$basearch/
gpgcheck=1
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-7

[updates]
name=CentOS-$releasever - Updates
baseurl=http://10.10.30.56/centos/\$releasever/updates/\$basearch/
gpgcheck=1
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-7

[extras]
name=CentOS-$releasever - Extras
baseurl=http://10.10.30.56/centos/\$releasever/extras/\$basearch/
gpgcheck=1
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-7
EOF


cat <<EOF> /etc/yum.repos.d/CentOS-Epel.repo
[epel]
name=Extra Packages for Enterprise Linux 7
baseurl=http://10.10.30.56/epel/7/x86_64/
failovermethod=priority
enabled=1
gpgcheck=1
gpgkey=http://10.10.30.56/epel/7/x86_64/RPM-GPG-KEY-EPEL-7
EOF
```

## Nguồn

https://computingforgeeks.com/how-to-create-centos-8-local-repository-mirrors-with-rsync-nginx/

https://admin.fedoraproject.org/mirrormanager/

https://cuongquach.com/tao-mirror-local-epel-repository-tren-centos.html