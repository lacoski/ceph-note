# 
---
IO Request truyền qua nhiều tầng. Các lớp được xây dựng trên nhau. VD, app và fs later đuoặc xây dựng trên lớp block virtualization. Tơi gần phần cứng, ta sẽ tgaast block layer, SCSI layer và các thiết bị (RAID controller, HBA, ..)

1 số tầng có sẵn cacge. Thược hiện với 2 nhiệm vụ. Buffer data theo yêu cầu, cung câp hiệu năng tốt hơn, gộp các request nhỏ thành các request lớn. Hoạt động này thực hiện trên cả hoạt động write and read. Đối với hoạt động đọc, có hoạt động cache khác là 'read ahead'(đọc trước), truy cập các khối lân cận mà không cần có request cụ thể, lưu trữ (có thể được sử dụng hoặc không).

Thuật ngữ "storage benchmark" nói đến hoạt động đánh giá IO truyền từ FS tới các tầng bên dưới. 

# Thông số
Throughput là 
