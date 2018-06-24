## GET SOFTWARE
yum install yum-plugin-priorities -y

sudo rpm --import 'https://download.ceph.com/keys/release.asc'

vi /etc/yum.repos.d/ceph.repo
```
[ceph]
name=Ceph packages for $basearch
baseurl=https://download.ceph.com/rpm-luminous/el7/$basearch
enabled=1
priority=2
gpgcheck=1
gpgkey=https://download.ceph.com/keys/release.asc

[ceph-noarch]
name=Ceph noarch packages
baseurl=https://download.ceph.com/rpm-luminous/el7/noarch
enabled=1
priority=2
gpgcheck=1
gpgkey=https://download.ceph.com/keys/release.asc

[ceph-source]
name=Ceph source packages
baseurl=https://download.ceph.com/rpm-luminous/el7/SRPMS
enabled=0
priority=2
gpgcheck=1
gpgkey=https://download.ceph.com/keys/release.asc
```

yum install snappy leveldb gdisk python-argparse gperftools-libs -y

sudo yum install -y yum-utils && sudo yum-config-manager --add-repo https://dl.fedoraproject.org/pub/epel/7/x86_64/ && sudo yum install --nogpgcheck -y epel-release && sudo rpm --import /etc/pki/rpm-gpg/RPM-GPG-KEY-EPEL-7 && sudo rm /etc/yum.repos.d/dl.fedoraproject.org*

yum update -y


sudo yum install ceph -y

Create a Ceph configuration file. By default, Ceph uses ceph.conf, where ceph reflects the cluster name.

## Setup firewall, SELinux
Tat toan bo
```
systemctl stop firewalld
systemctl disable firewalld
setenforce 0
sed -i 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/selinux/config

```

## MONITOR BOOTSTRAPPING
Access monitor node

Generate a unique
vim /etc/ceph/ceph.conf

Add the unique ID to your Ceph configuration file.
> Sinh UUID = cmd : uuidgen
```
fsid = {UUID}

VD:
fsid = a7f64266-0894-4f1e-a635-d0aeaca0e993
```

Add the initial monitor(s) to your Ceph configuration file.
```
mon initial members = {hostname}[,{hostname}]

VD:
mon initial members = node1 # Chú ý tên này
```
> Chú ý tên mon node phải trùng với mon node khi tạo (nếu không sẽ không thể show được ceph status)

Add the IP address(es) of the initial monitor(s) to your Ceph configuration file and save the file.
```
mon host = {ip-address}[,{ip-address}]

VD:
mon host = 192.168.0.1 # chú ý ip này
```

Create a keyring for your cluster and generate a monitor secret key.
```
ceph-authtool --create-keyring /tmp/ceph.mon.keyring --gen-key -n mon. --cap mon 'allow *'
```

Generate an administrator keyring, generate a client.admin user and add the user to the keyring.
```
sudo ceph-authtool --create-keyring /etc/ceph/ceph.client.admin.keyring --gen-key -n client.admin --set-uid=0 --cap mon 'allow *' --cap osd 'allow *' --cap mds 'allow *' --cap mgr 'allow *'
```

Generate a bootstrap-osd keyring, generate a client.bootstrap-osd user and add the user to the keyring.
```
sudo ceph-authtool --create-keyring /var/lib/ceph/bootstrap-osd/ceph.keyring --gen-key -n client.bootstrap-osd --cap mon 'profile bootstrap-osd'
```

Add the generated keys to the ceph.mon.keyring.
```
sudo ceph-authtool /tmp/ceph.mon.keyring --import-keyring /etc/ceph/ceph.client.admin.keyring
sudo ceph-authtool /tmp/ceph.mon.keyring --import-keyring /var/lib/ceph/bootstrap-osd/ceph.keyring
```

Sau bước này cần chỉnh sửa lại quyền 2 file:
- /tmp/monmap
- /tmp/ceph.mon.keyring
- Thư mục chứ mon service

```
cd /tmp
chown ceph ceph.mon.keyring
chown ceph monmap
```

Generate a monitor map using the hostname(s), host IP address(es) and the FSID. Save it as /tmp/monmap:
```
monmaptool --create --add {hostname} {ip-address} --fsid {uuid} /tmp/monmap

VD:
monmaptool --create --add node1 192.168.0.1 --fsid a7f64266-0894-4f1e-a635-d0aeaca0e993 /tmp/monmap
```
> Chú ý tên hostname (phải cùng tên trong Ceph.confm, chú ý cả ip address)

Create a default data directory (or directories) on the monitor host(s).
```
sudo mkdir /var/lib/ceph/mon/{cluster-name}-{hostname}

VD:
mkdir /var/lib/ceph/mon/ceph-node1
chown -R ceph /var/lib/ceph/mon/ceph-node1
```

Populate the monitor daemon(s) with the monitor map and keyring.
```
sudo -u ceph ceph-mon [--cluster {cluster-name}] --mkfs -i {hostname} --monmap /tmp/monmap --keyring /tmp/ceph.mon.keyring

VD:
sudo -u ceph ceph-mon --mkfs -i node1 --monmap /tmp/monmap --keyring /tmp/ceph.mon.keyring
```

Consider settings for a Ceph configuration file. Common settings include the following:
```
[global]
fsid = {cluster-id}
mon initial members = {hostname}[, {hostname}]
mon host = {ip-address}[, {ip-address}]
public network = {network}[, {network}]
cluster network = {network}[, {network}]
auth cluster required = cephx
auth service required = cephx
auth client required = cephx
osd journal size = {n}
osd pool default size = {n}  # Write an object n times.
osd pool default min size = {n} # Allow writing n copies in a degraded state.
osd pool default pg num = {n}
osd pool default pgp num = {n}
osd crush chooseleaf type = {n}

VD:
global]
fsid = cf9343ab-1662-43b6-9fcb-82588a0c8f23
mon initial members = mon1
mon host =  192.168.2.151

public network = 192.168.2.0/24
cluster network = 192.168.3.0/24
auth cluster required = cephx
auth service required = cephx
auth client required = cephx

osd journal size = 1024
osd pool default size = 3
osd pool default min size = 2
osd pool default pg num = 333
osd pool default pgp num = 333
osd crush chooseleaf type = 1
```

Touch the done file.
> Mark that the monitor is created and ready to be started:

```
sudo touch /var/lib/ceph/mon/ceph-node1/done
sudo touch /var/lib/ceph/mon/ceph-node1/upstart
```

Start the monitor(s).
```
sudo systemctl start ceph-mon@node1
sudo systemctl enable ceph-mon@mon1
sudo systemctl status ceph-mon@node1
```

Verify that the monitor is running.
```
[root@ceph-admin mgr]# ceph -s
  cluster:
    id:     cf9343ab-1662-43b6-9fcb-82588a0c8f23
    health: HEALTH_OK

  services:
    mon: 1 daemons, quorum mon1
    mgr: mgr-1(active)
    osd: 0 osds: 0 up, 0 in

  data:
    pools:   0 pools, 0 pgs
    objects: 0 objects, 0 bytes
    usage:   0 kB used, 0 kB / 0 kB avail
    pgs:     
```

## Create MANAGER DAEMON CONFIGURATION - MGR
create an authentication key for your daemon:
```
ceph auth get-or-create mgr.$name mon 'allow profile mgr' osd 'allow *' mds 'allow *'

VD:
ceph auth get-or-create mgr.mgr-1 mon 'allow profile mgr' osd 'allow *' mds 'allow *'
```

Chuyển key vừa sinh tới thư mục `/var/lib/ceph/mgr/ceph-mgr-1`
```
vi /var/lib/ceph/mgr/ceph-mgr-1
```
Nội dung
```
[mgr.mgr-1]
	key = AQDI4i9bGZXaHRAA6EYM/UAKChfRlBb3qyOHYA==
```

Start the ceph-mgr daemon:
```
ceph-mgr -i $name

or

systemctl status ceph-mgr@mgr-1
systemctl enable ceph-mgr@mgr-1
```

Check status
```
[root@ceph-admin mgr]# ceph -s
  cluster:
    id:     cf9343ab-1662-43b6-9fcb-82588a0c8f23
    health: HEALTH_OK

  services:
    mon: 1 daemons, quorum mon1
    mgr: mgr-1(active) # mgr vừa tạo
    osd: 0 osds: 0 up, 0 in

  data:
    pools:   0 pools, 0 pgs
    objects: 0 objects, 0 bytes
    usage:   0 kB used, 0 kB / 0 kB avail
    pgs:     
```

## ADDING OSDS

Create the OSD.
> Cần tạo Tạo Partition trên ổ địa (fdisk /dev/...)
> Các node OSD cần được chia sẻ key từ node admin (/var/lib/ceph/bootstrap-osd/ceph.keyring)

### BLUESTORE
Lựa chọn 1:
```
ssh {node-name}
sudo ceph-volume lvm create --data {data-path}

VD:
ssh node1
sudo ceph-volume lvm create --data /dev/hdd1
```

Lựa chọn 2:
Prepare the OSD.
```
ssh {node-name}
sudo ceph-volume lvm prepare --data {data-path} {data-path}

VD:
ssh node1
sudo ceph-volume lvm prepare --data /dev/hdd1
```

Once prepared, the ID and FSID of the prepared OSD are required for activation. These can be obtained by listing OSDs in the current server:
```
sudo ceph-volume lvm list

```

Activate the OSD:
```
sudo ceph-volume lvm activate {ID} {osd fsid}
VD:
sudo ceph-volume lvm activate 0 a7f64266-0894-4f1e-a635-d0aeaca0e993
```

Chú ý:
Nếu không thể lấy status Ceph -s, kiểm tra status mon server, nếu kích hoạt service nếu server đang stop
```
systemctl status ceph-mon@mon1
systemctl start ceph-mon@mon1
```


## Vấn đề
Nếu Node Mon chết, trong thời gian node mon chết có sự kiện sảy ra OSD chết => không update trạng theo Ceph status (ceph -s)
