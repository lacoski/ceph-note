# Hướng dẫn Backup gói Ceph

## Chuẩn bị

Version CentOS 7: 7.9.2009

## Phần 1: Backup gói Local Repo

epel-release byobu nginx createrepo yum-utils wget chrony

## Phần 2: Tạo Repo Ceph

python3 python3-pip byobu git

### Gói RPM Ceph

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

### Gói PIP

pip3 install virtualenv

### Github

git clone https://github.com/ceph/ceph-ansible
git checkout stable-4.0
pip3 install -r requirements.txt