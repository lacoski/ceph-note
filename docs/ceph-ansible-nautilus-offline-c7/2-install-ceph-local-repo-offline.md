# Hướng dẫn triển khai Ceph Local Repo Offline bản Nautilus

## Chuẩn bị

Backup gói Ceph Nautilus tài liệu:
- [Hướng dẫn triển khai Ceph Local Repo bản Nautilus](/docs/ceph-ansible-nautilus-offline-c7/1-backup-ceph-local-repo.md)

Copy thư mục `backup-local-repo` và `backup-ceph-rpm` tới node Ceph Backup

Kiểm tra
```
[root@cephbackup3056 ~]# ll
total 12
-rw-------. 1 root root 1468 17:49 24 Th11 anaconda-ks.cfg
drwxr-xr-x  6 root root 4096 04:07 25 Th11 backup-ceph-rpm
drwxr-xr-x  5 root root 4096 08:55 25 Th11 backup-local-repo
```

Disable gateway để tránh cài gói từ internet

## Bước 1: Cài đặt NTP
```
yum localinstall -y /root/backup-local-repo/01-chrony/*.rpm
```

Cấu hình
```
NTP_SERVER_IP='10.10.30.15'
sed -i '/server/d' /etc/chrony.conf
echo "server $NTP_SERVER_IP iburst" >> /etc/chrony.conf
systemctl enable chronyd.service
systemctl restart chronyd.service
chronyc sources
```

## Bước 2: Cài đặt Nginx và các gói hỗ trợ
```
yum localinstall -y /root/backup-local-repo/03-extra/*.rpm
```

Khởi động nginx
```
systemctl start nginx
systemctl enable nginx
systemctl status nginx
```

## Bước 3: Tạo Repo Ceph

Tạo thư mục
```
mkdir -p /var/www/html/repos/
```

Copy thư mục backup rpm tới `/var/www/html/repos/`
```
cp -r /root/backup-ceph-rpm/* /var/www/html/repos/
```

Xóa repodata mặc định
```
cd /var/www/html/repos/x86_64/ && rm -rf repodata index.html
cd /var/www/html/repos/SRPMS/ && rm -rf repodata index.html
cd /var/www/html/repos/noarch/ && rm -rf repodata index.html
```

Khởi tạo repo
```
createrepo -v /var/www/html/repos/SRPMS/
createrepo -v /var/www/html/repos/x86_64/
createrepo -v /var/www/html/repos/noarch/
```

Cấu hinh nginx
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

https://news.cloud365.vn/ceph-lab-huong-dan-cai-dat-ceph-chi-dinh-minor-version-tren-centos-7/
