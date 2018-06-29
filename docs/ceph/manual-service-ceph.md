# Quản lý service Ceph với systemd service
---
## 1. Chạy, dừng, khởi động lại tất cả tiến trình
Để chạy, dừng, restart tất cả tiến trình trên Ceph Node (Tại chính node thực hiện)

### Chạy tất cả dịch vụ
```
systemctl start ceph.target
```

### Dừng tất cả dịch vụ
```
systemctl stop ceph.target
```

### Khởi động lại tất cả dịch vụ
```
systemctl restart ceph.target
```

## 2. Chạy, dừng, khởi động lại tiến trình theo loại
### Tất cả tiến trình Monitor
__Chạy__
```
systemctl start ceph-mon.target
```

__Dừng__
```
systemctl stop ceph-mon.target
```

__Khởi động lại__
```
systemctl restart ceph-mon.target
```

### Tất cả tiến trình OSD
__Chạy__
```
systemctl start ceph-osd.targe
```

__Dừng__
```
systemctl stop ceph-osd.target
```

__Khởi động lại__
```
systemctl restart ceph-osd.target
```

### Tất cả tiến trình RADOS Gateway
__Chạy__
```
systemctl start ceph-radosgw.target

```

__Dừng__
```
systemctl stop ceph-radosgw.targe
```

__Khởi động lại__
```
systemctl restart ceph-radosgw.target
```


## 2. Chạy, dừng, khởi động tiến trình được chọn
### Tiến trình Monitor
__Chạy__
```
systemctl start ceph-mon@<monitor_hostname>
```

__Dừng__
```
systemctl stop ceph-mon@<monitor_hostname>
```

__Khởi động lại__
```
systemctl restart ceph-mon@<monitor_hostname>
```

### Tiến trình OSD
__Chạy__
```
systemctl start ceph-osd@<OSD_number>
```

__Dừng__
```
systemctl stop ceph-osd@<OSD_number>
```

__Khởi động lại__
```
systemctl restart ceph-osd@<OSD_number>
```

### Tiến trình RADOS Gateway
__Chạy__
```
systemctl start ceph-radosgw@rgw.<gateway_hostname>
```

__Dừng__
```
systemctl stop ceph-radosgw@rgw.<gateway_hostname>
```

__Khởi động lại__
```
systemctl restart ceph-radosgw@rgw.<gateway_hostname>
```