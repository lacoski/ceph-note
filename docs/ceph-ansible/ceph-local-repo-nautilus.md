yum install epel-release -y

yum install byobu -y

yum install nginx -y

systemctl start nginx
systemctl enable nginx
systemctl status nginx

byobu

yum install createrepo yum-utils wget -y

mkdir -p /var/www/html/repos/{SRPMS,x86_64,noarch}

cd /var/www/html/repos/SRPMS && wget  -nH --cut-dirs=3 -r --no-parent https://download.ceph.com/rpm-nautilus/el7/SRPMS/
cd /var/www/html/repos/noarch && wget  -nH --cut-dirs=3 -r --no-parent https://download.ceph.com/rpm-nautilus/el7/noarch/
cd /var/www/html/repos/x86_64 && wget -r -nH --cut-dirs=3 --no-parent -A '*-12.2.12-0.el7.x86_64.rpm' https://download.ceph.com/rpm-nautilus/el7/x86_64/
