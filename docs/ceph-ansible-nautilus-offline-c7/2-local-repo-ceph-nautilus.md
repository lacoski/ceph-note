# Hướng dẫn triển khai Ceph Local Repo bản Nautilus

## Lưu ý

- Mục tiêu backup Repo Ceph phiên bản Nautilus phục vụ cài Ceph hoàn toàn offline

## Bước 1: Chuẩn bị môi trường
```
yum install epel-release -y
```

Cài đặt byobu
```
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

## Bước 3: Tạo Repo Ceph

Khởi động byobu
```
byobu
```

Cài đặt gói quản lý repo

```
yum install createrepo yum-utils wget -y
```

Tải về các gói Ceph
```
mkdir -p /var/www/html/repos/{SRPMS,x86_64,noarch}
cd /var/www/html/repos/SRPMS && wget  -nH --cut-dirs=3 -r --no-parent https://download.ceph.com/rpm-nautilus/el7/SRPMS/
cd /var/www/html/repos/noarch && wget  -nH --cut-dirs=3 -r --no-parent https://download.ceph.com/rpm-nautilus/el7/noarch/
cd /var/www/html/repos/x86_64 && wget -r -nH --cut-dirs=3 --no-parent -A '*-14.2.14-0.el7.x86_64.rpm' https://download.ceph.com/rpm-nautilus/el7/x86_64/

mkdir -p /var/www/html/repos/keys
cd /var/www/html/repos/keys && wget  -nH --cut-dirs=3 -r --no-parent https://download.ceph.com/keys/
```

Xóa repodata mặc định
```
cd /var/www/html/repos/x86_64/ && rm -rf repodata index.html
cd /var/www/html/repos/SRPMS/ && rm -rf repodata index.html
cd /var/www/html/repos/noarch/ && rm -rf repodata index.html
```

Lọc các packages trong thư mục /var/www/html/repos/SRPMS/ chỉ giữ lại version 14.2.14
```
rm -rf $(ls /var/www/html/repos/SRPMS/ -I "ceph-14.2.14-0.el7.src.rpm" | grep ceph-14)
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
        server_name  10.10.30.51;
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

Kiểm tra, truy cập http://10.10.30.51/


## Nguồn

https://news.cloud365.vn/ceph-lab-huong-dan-cai-dat-ceph-chi-dinh-minor-version-tren-centos-7/
