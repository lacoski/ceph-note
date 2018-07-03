# Cách cập nhật Config Ceph
---
## Bước 1: Đẩy config xuống các node
### DEPLOY CONFIG FILE
> Thực hiện từ node admin
```
ceph-deploy config push {host-name [host-name]...}
```
### RETRIEVE CONFIG FILE
> Thực hiện từ node chịu sử quản lý của admin
```
ceph-deploy config pull {host-name [host-name]...}
```

## Bước 2: Khởi động lại tiến trình Mon
> Khởi động lại Mon service trên tất cả các node

```
systemctl restart ceph-mon.target
```