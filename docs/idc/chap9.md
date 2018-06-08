# Storage Services and Systems
# Tổng quan
công nghệ Data storage được sử dụng để lưu, truy cập, sử dụng cho app, vm (trong or ngoài mạng). Có nhiều loại storage để phục vụ các yêu cầu khác nhau.

Các storage có thể được tìm thấy trong SAN, NAS, cloud system, server, workstations, laptop, ... Các loại storage khác nhau có tính năng, chức năng, mục đích, kiến trúc, giá thành, chất lượng khác nhau. 1 số giải pháp storage tập trung cho 1 mục đích nhất được, 1 số khác phục vụ cho thương mai.

> 1 số storage được xây dựng dạng opensource software

Các tính chất cơ bản storage:
- Internal or external to a server, or dedicated or shared with others
- Performance in bandwidth, activity, or IOPS and response time or latency
- Availability and reliability, including data protection and redundant components
- Capacity or space for saving data on a storage medium
- Energy and economic attributes for a given configuration
- Functionality and additional capabilities beyond read/write or storing data

Góc nhìn cơ bản storage

## Tiered Storage
Mục đích của Tiered storage là định hình các loại storage system, các mức hiệu suất khác nhau, availability, capacity, and energy or economics (PACE) capabilities để đáp ứng các yêu cầu của ứng dụng.

Các thiết bị lưu trữ như ssd, hdd thường được sử dụng cho tiered storage.

Storage tiering có định nghĩa khác nhau đối với từng góc nhìn. VD 1 số cho rằng nó mô tả sự lưu trữ hoặc các hệ thống lưu trữ sử dụng cho hoạt động kinh doanh, ứng dụng, cung cấp các dịch vụ lưu trữ. 1 số phân loại storage tiers bằng giá và số tiền phải trả cho giải pháp. 1 số khác coi nó là size và capacity hoặc tính năng

## Storage Reliability, Availability, and Serviceability (RAS)
Mục đích cơ bản storage là đảm bảo tính toàn vẹn dữ liệu. Tất cả công nghệ, bao gồm storage đều có thể lỗi - phát sinh từ phần cứng hoặc phần mêm - do tác động con người, do điều kiện môi trường, các vấn đề do năng lượng, làm mát, ...

Storage reliability, availability, and serviceability combines:
- Redundant components: power, cooling, controllers, spare disks
- Fault containment: automatic leveraging of redundant components
- Self-healing: error correction, data integrity checks, rebuild and repair
- High availability: redundant components, replication with snapshots
- Business continuance: failover or restart at alternate site
- Disaster recovery: rebuild, restore, restart, and resume at alternative site
- Management tools: Notification, diagnostics, remediation and repair

Để bảo đảm storage reliability, availability, and serviceability, các yêu cầu phải đáp ứng:

pic 23 24

## Aligning Storage Technology and Media to Application Needs
Do sự đa dạng các loại dữ liệu từ trực tuyến => ngoại tuyến, tính truy cập khác nhau vì vậy giải pháp lưu trữ cần tối ưu theo nhiều hướng khác nhau để đáp ứng, tối ưu hóa trên từng vấn đề.

pic 25

Tiered storage bao gồm các thiết bị từ tốc độ nhanh, hiệu năng cao tới hiệu năng chậm nhưng độ chứa lớn.

Đối với tier 0, sử dụng SSD và cache cung cấp khả năng IOPS tốt, độ trễ thấp, đánh đổi là khả năng lưu trữ và giá cả.

Với tier 1, không yêu cầu độ trễ thấp nhưng vấn cần hiệu năng cao, dung lượng lớn => Lựa chọn có hdd 15k RPM, nó sẽ vừa đủ đáp ứng yêu cầu về IOPS, băng thông và khả năng lưu trữ.

Với tier 2 3, sẽ sử dụng cho data có tần suất truy xuất thấp, đòi hỏi khả năng lưu cao (hàng trăm tb)

Vấn đề cần cân nhắc khác là RAID, sự đánh đổi hiệu năng >< khả năng lưu trữ giữa các loại RAID

(Các loại ổ cứng và Raid )

Đánh đổi giữa chất lượng và giá thành

pic 26

## Storage System Architectures

243 / 25
