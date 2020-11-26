mkdir -p /var/www/html/repos/centos/7/{os,updates,extras}/x86_64

chmod -R 755 /var/www/html/repos

cd /var/www/html/repos

rsync -avz --delete --exclude='repodata' \
rsync://ftp.riken.jp/centos/7/os/x86_64/ \
/var/www/html/repos/centos/7/os/x86_64/

rsync -avz --delete --exclude='repodata' \
rsync://ftp.riken.jp/centos/7/updates/x86_64/ \
/var/www/html/repos/centos/7/updates/x86_64/

rsync -avz --delete --exclude='repodata' \
rsync://ftp.riken.jp/centos/7/extras/x86_64/ \
/var/www/html/repos/centos/7/extras/x86_64/

createrepo /var/www/html/repos/centos/7/os/x86_64/
createrepo /var/www/html/repos/centos/7/updates/x86_64/
createrepo /var/www/html/repos/centos/7/extras/x86_64/


vi /etc/yum.repos.d/CentOS-Base.repo

[base]
name=CentOS-$releasever - Base
baseurl=http://10.10.30.56/repos/centos/$releasever/os/$basearch/
gpgcheck=1
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-7

[updates]
name=CentOS-$releasever - Updates
baseurl=http://10.10.30.56/repos/centos/$releasever/updates/$basearch/
gpgcheck=1
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-7

[extras]
name=CentOS-$releasever - Extras
baseurl=http://10.10.30.56/repos/centos/$releasever/extras/$basearch/
gpgcheck=1
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-7