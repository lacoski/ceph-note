# Hướng dẫn Backup Ceph Ansible Octopus (Cài từ Git) - CentOS 8

## Lưu ý:
- Mục tiêu Backup source Ceph Ansible từ Git phục vụ cài Ceph Ansible hoàn toàn từ local
- Môi trường CentOS 8

## Chuẩn bị

Tạo thư mục
```
mkdir -p /root/backup-ceph-ansible-octopus/
```

Cài môi trường cần thiết
```
yum install python3 python3-pip git -y
```

## Bước 1: Backup Ceph Ansible từ Git

```
mkdir -p /root/backup-ceph-ansible-octopus/01-ceph-ansible/
cd /root/backup-ceph-ansible-octopus/01-ceph-ansible/ && wget https://github.com/ceph/ceph-ansible/archive/stable-5.0.zip
cd
```

## Bước 3: Backup gói pip
> Lưu ý: Lấy nội dung tư requirements.txt của Ceph Ansible

```
mkdir -p /root/backup-ceph-ansible-octopus/02-pip/
mkdir -p /root/backup-ceph-ansible-octopus/02-pip/virtualenv
mkdir -p /root/backup-ceph-ansible-octopus/02-pip/requirements

cd /root/backup-ceph-ansible-octopus/02-pip/virtualenv
pip3 download -d /root/backup-ceph-ansible-octopus/02-pip/venv virtualenv
pip3 install --no-index --find-links=/root/backup-ceph-ansible-octopus/02-pip/venv virtualenv

cd /root/backup-ceph-ansible-octopus/02-pip/requirements

cat <<EOF> /root/backup-ceph-ansible-octopus/02-pip/requirements.txt
ansible>=2.9,<2.10,!=2.9.10
netaddr
EOF

cd /root/
virtualenv env -p python3
source env/bin/activate
pip3 download -d /root/backup-ceph-ansible-octopus/02-pip/requirements -r /root/backup-ceph-ansible-octopus/02-pip/requirements.txt
pip3 install --no-index --find-links=/root/backup-ceph-ansible-octopus/02-pip/requirements -r /root/backup-ceph-ansible-octopus/02-pip/requirements.txt
```

Kết quả
```
(env) [root@repocent8 backup-ceph-ansible-octopus]# tree
.
├── 01-ceph-ansible
│   └── stable-5.0.zip
└── 02-pip
    ├── requirements
    │   ├── ansible-2.9.15.tar.gz
    │   ├── cffi-1.14.4-cp36-cp36m-manylinux1_x86_64.whl
    │   ├── cryptography-3.2.1-cp35-abi3-manylinux2010_x86_64.whl
    │   ├── importlib_resources-3.3.0-py2.py3-none-any.whl
    │   ├── Jinja2-2.11.2-py2.py3-none-any.whl
    │   ├── MarkupSafe-1.1.1-cp36-cp36m-manylinux1_x86_64.whl
    │   ├── netaddr-0.8.0-py2.py3-none-any.whl
    │   ├── pycparser-2.20-py2.py3-none-any.whl
    │   ├── PyYAML-5.3.1.tar.gz
    │   ├── six-1.15.0-py2.py3-none-any.whl
    │   └── zipp-3.4.0-py3-none-any.whl
    ├── requirements.txt
    ├── venv
    │   ├── appdirs-1.4.4-py2.py3-none-any.whl
    │   ├── distlib-0.3.1-py2.py3-none-any.whl
    │   ├── filelock-3.0.12-py3-none-any.whl
    │   ├── importlib_metadata-3.1.0-py2.py3-none-any.whl
    │   ├── importlib_resources-3.3.0-py2.py3-none-any.whl
    │   ├── six-1.15.0-py2.py3-none-any.whl
    │   ├── virtualenv-20.2.1-py2.py3-none-any.whl
    │   └── zipp-3.4.0-py3-none-any.whl
    └── virtualenv

5 directories, 21 files
```