# Hướng dẫn triển khai Local Repo Mirros CentOS

## Lưu ý

- Local Repo sẽ chứa toàn bộ các gói cơ bản của CentOS 7

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
rsync -avz --delete --progress rsync://centos.mirror.hostinginside.com/CentOS/7/ /var/www/html/repos/centos/7/
chmod -R 755 /var/www/html/repos
```

## Bước 4: Tạo Repo Ceph

Tải về các gói Ceph
```
mkdir -p /var/www/html/repos/ceph/el7/
cd /var/www/html/repos/ceph/el7/
lftp -c 'mirror --parallel=100 https://download.ceph.com/ ;exit'
```

## Bước 5: Cấu hình Nginx

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


## Nguồn

https://computingforgeeks.com/how-to-create-centos-8-local-repository-mirrors-with-rsync-nginx/