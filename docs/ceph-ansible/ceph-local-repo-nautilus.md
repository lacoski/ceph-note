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

cd /var/www/html/repos/x86_64 && wget -r -nH --cut-dirs=3 --no-parent -A '*-14.2.14-0.el7.x86_64.rpm' https://download.ceph.com/rpm-nautilus/el7/x86_64/

## Chưa làm
mkdir -p /var/www/html/repos/keys

cd /var/www/html/repos/keys && wget  -nH --cut-dirs=3 -r --no-parent https://download.ceph.com/keys/



cd /var/www/html/repos/x86_64/ && rm -rf repodata index.html
cd /var/www/html/repos/SRPMS/ && rm -rf repodata index.html
cd /var/www/html/repos/noarch/ && rm -rf repodata index.html


rm -rf $(ls /var/www/html/repos/SRPMS/ -I "ceph-12.2.12-0.el7.src.rpm" | grep ceph-12)


createrepo -v /var/www/html/repos/SRPMS/
createrepo -v /var/www/html/repos/x86_64/
createrepo -v /var/www/html/repos/noarch/


https://news.cloud365.vn/ceph-lab-huong-dan-cai-dat-ceph-chi-dinh-minor-version-tren-centos-7/