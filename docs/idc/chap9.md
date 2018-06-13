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

Storage solutions tập trung vào kiến trúc hoặc tính đóng gói của storage system, giải pháp từ nhỏ tới các hệ thống lớn, các hệ thống doanh nghiệp chuyên dụng. Các hệ thống khác nhau sẽ sử dụng các giao thức, protocol chuẩn hóa, được định nghĩa theo quy chuẩn, tuân theo kiến trúc storage system, tính tương thích cao.

Ngoài việc hỗ trợ các hệ thống mở, tương thích các mainframe, Highend cache-centric storage system, các hệ thống còn hỗ trợ tới hàng nghìn hdds, bao gồm cả các SSD, SAS HDD, các chuẩn kết nối tốc độ cao.

## Servers as Storage, Storage as Servers
"Open storage" có nghĩa là storage cho open system hoặc storage system sửa dụng công nghệ mở. Giá trị của storage system là tận dụng tính mở của kỹ thuật mở, tính linh hoạt trong lựa chọn storage software stack, khả năng chạy giải pháp trên phần cứng được chọn, trái ngược với giải pháp trọn gói (tính đóng gói cao, khả năng tùy chỉnh thấp). 2 công nghệ thường thấy là ZFS hoặc Microsoft Windows Storage Server

pic 27

Storage systems (Table 9.6), gateways, and appliances (thiết bị) sử dụng công nghệ mở bao gồm 1 phần mềm chuyên dụng hoặc tool quản trị storage chạy trên thiết bị mở hoặc trên phần cứng chuấn x86-based PC server. 1 số giải pháp khác cho openstorage là sử dụng các open source software chạy trên các phần cứng mở (đa dạng) thay vì các phần mềm chuyên dụng độc quyền.

> For some of the solutions, internal dedicated SAS, SATA, and/or SSD disk drives are
used. Other solutions may use a mix of internal and external or all external storage,
either JBOD (Just a Bunch Of Disks) enclosure shelves or complete storage systems

Như bảng trên, các storage thương sử dụng các công nghệ mở, trên các phần cứng đặc biệt, đó là các cloud gateway hoặc các thiết bị chuyên dụng. 1 số trường hợp  cloud access gateways or appliances, local storage có thể bao gồm các giải pháp cache, buffer, temporary area, khả năng snapshot, backup, 1 số tính năng di chuyên data trên cloud. Rất nhiều giải pháp cloud, service hoặc các nhà cung cấp service tận dụng nhiều công nghệ khác nhau để tạo sự đa dạng service trong cloud.

# Clustered and Grid Storage
Clustered and grid storage, được biết là khả năng bao hàm hoặc tính mở rộng của hệ thống, chúng là thể là block, file, object based storage, bao gồm nhiều tính năng khác nhau. Hạ tầng các tổ chức thường rất lớn, phức tạc, đòi hỏi tính tinh hoạt => cluster storage có khả năng đáp ứng được các yêu cầu trên (performance, availability, capacity, and functionality). Từ góc nhìn hiệu năng, 1 số hệ thống được tối ưu cho khả năng đọc ghi random hoặc liên tiếp phục vụ hoạt động các file, web page, truy xuất metadata. 1 số hệ thống khác được tối ưu cho khả năng truy xuất liên tiếp lớn như các video, image, các dữ liệu phúc tạp, khi các giải pháp được trộn lẫn. 1 số giải pháp mở rộng hiệu năng với dung lương tối thiểu, 1 số khác tối ưu cho khả năng lưu trữ lớn. Từ đó, ta thấy được cluster or grid storage solution không tự suy luận ra được quy mô, hiểu năng, khả năng lưu trữ của storage system.

> The term cluster means different things to different people, particularly when clustered storage is combined with NAS or file-based storage

Clustered storage solutions có thể truy cập trông qua block  (iSCSI, FC, or FCoE), file (NFS, pNFS, or CIFS), object, HTTP, APIs, or proprietary approaches (1 sô pp khác). Clustered Storage giống với clustered servers, cung cấp khả năng mở rộng không giới hạn - scale for performance, scale for availability, and scale for capacity and to enable growth in a modular fashion—adding performance and intelligence capabilities along with capacity.

Đối với các hạ tầng nhỏ, clustered storage cho phép tính modular cung cấp khả năng  pay-as-you-grow, mở rộng khi cần. Đối với hạ tầng lơn, cluster storage cho phép mở rộng không giới hạn, đáp ứng các yêu cầu performance, capacity, or availability.

Các application sử dụng clustered, bulk, grid, and “big data” storage solutions include:
- Unstructured data files
- Data warehouse, data mining, business analytics
- Collaboration including email, SharePoint, and messaging systems
- Home directories and file shares
- Web-based and cloud or managed service providers
- Backup/restore and archive
- Rich media, hosting, and social networking Internet sites
- Media and entertainment creation, animation rendering and postprocessing
- Financial services and telecommunications, call detail billing
- Project-oriented development, simulation, and energy exploration
- Look-up or reference data
- Fraud detection and electronic surveillance
- Life sciences, chemical research, and computer-aided design

Clustered storage solutions cần đáp ứng các yêu cầu về large sequential parallel or concurrent file access, hỗ trợ pp truy cập ngẫy nhiên tới các small file. Scalable và flexible clustered file servers, tương tính các servers, networking, and storage technologies, cũng như đáp ứng được các công nghệ mới, yêu cầu lưu trữ dữ liệu không có cấu trúc, cloud services, and multimedia. Đáp ứng các yêu cầu về hiệu năng (IOPS, bandwidth), độ trễ thấp, dung lượng, tính linh hoạt và chi phí thấp.

pic 28

Scalable and flexible clustered file server and storage systems (tính mở dụng, linh hoạt trên file server, hệ thống lưu trữ) đáp ứng khả năng cải tiến phần cứng theo từng năm, tránh sự lạc hậu hạ tầng.

Các yêu cầu cần đáp ứng grid, clustered, big data, and scale-out storage:
- Can memory, processors, and I/O devices be varied?
- Is there support for large file systems with many small or large files?
- What is the performance for small, random, concurrent IOPS?
- What is the performance for single-threaded and parallel or sequential I/O?
- How is performance enabled across the same cluster instance?
- Can a file system and file be read and written to from all nodes concurrently?
- Are I/O requests, including meta-data look-up, sent to a single node?
- How does performance scale as nodes and storage are increased?
- How disruptive is adding new or replacing existing storage?
- Is proprietary hardware needed, or can industry-standard components be used?
- What data management features, including load balancing, exist?
- What interface and protocol options are supported?

## Cloud Storage
pic 29
Cloud storage (Figure 9.11) có thể public, private, có kiến trúc, 1 sản phẩm, hoặc giải pháp bao gồm hardware, software, networking, services. 1 số cloud storage services hoặc giải pháp tập trung vào các vấn đề cụ thể (file sharing, backup/restore, archiving, BC/DR, lưu trữ data dạng multimedia như photos, video, and audio.).

1 số sản phẩn cloud service tối ưu cho security, database or email and Web hosting, healthcare electronic medical records (EMR), or digital asset management (DAM), including Picture Archiving Communication Systems (PACS).

Có nhiều cách để truy cập Cloud storage, nó sẽ dựa trên loại service hoặc sản phẩm. 1 số truy cập dựa trên NAS file-based interface, hoặc truy cập qua gateway, các thiết bị, 1 số software driver module. Bên cạnh đó, cloud storage cũng cung cấp các giao thức mở rộng, cho phép truy cập qua cloud appliances or gateways. Data lưu trên cloud cung cấp, hỗ trợ tính năng như replication, snapshot, babandwidth optimization, security, metering, reporting, and other capabilities. Cloud services tận dụng nhiều giải pháp khác nhau để đa dạng giải pháp cung cấp (VD: Google)

## Storage Virtualization and Virtual Storage
Có nhiều loại storage virtualization, bao gồm aggregation hoặc  pooling, emulation, and abstraction of different tiers of physical storage providing transparency of physical resources

Storage virtualization có thể thấy tại nhiều địa điểm khác nhau như server software, app server, các OS, trong các thiết bị, cũng như các storage systems.

### Volume Mangers and Global Name Spaces
1 Hình thể cơ bản của storage virtualization là volume manager, nó trừ tượng physical storage cho app và file system. Bên cạnh đó cung cấp các sự trừ tượng khác nhau cho các công nghệ khác nhau. Volume manager cũng được sử dụng để hỗ trợ sự tập hợp (aggregation), tối ưu hiệu năng, infrastructure resource management (IRM) functions.

Volume manager cung cấp lớp trừ tượng, cho phép các loại physical storage khác nhau được thêm, loại bỏ, phục vụ cho hoạt động bảo dưỡng, nâng cấp mà không gây ảnh hưởng tới app và file system.

> Các tính năng IRM được hỗ trợ trong volume manager, bao gồm storage allocation, provisioning, data protection operations như snapshots và replication; Các phương pháp này sẽ khác nhau tùy theo nhà cung cấp.

> File systems bao gồm clustered và distributed systems, có thể được xây dựng bên trên liên kết với các volume managers để hỗ trợ việc mở rộng(scaling) bảo đảm performance, availability, and capacity.

Global name spaces cung cấp các dạng dạng khác nhau để tạo các tập hợp, trừ tượng trên nhiều file system khác nhau. Global name space có thể nằm trên nhiều file system khác nhau, cung cấp giao diện truy cập, dễ dàng cho việc quản trị.

### Virtualization and Storage Services
Virtual storage và storage virtualization cho phép agility, resiliency, flexibility,
and data and resource mobility to simplify IRM. 1 số storage virtualization solutions tập trung vào sự hợp nhất và pooling. Có nghĩa là mở rộng, tập trung vào tính ảo hóa và sự hợp nhất, tập hợp các LUN, bảo đảm tính agility, flexibility, data or system movement, technology refresh, and other common time-consuming IRM tasks.

Nhiều loại storage virtualization services thực hiện trên các các địa điểm khác nhau đễ hỗ trợ nhiều tác vụ. Tính năng Storage virtualization bao gồm pooling, aggregation
trên cả block- và file-based storage, khả năng tương tác với tài nguyên IT hardware và software, các virtual file system, di chuyển dữ liệu trên hoạt động nâng cấp, bảo trì, hỗ trợ tính high availability (HA), business continuance(BC), và disaster recovery (DR).

Storage virtualization functionalities include:
- Pooling or aggregation of storage capacity
- Transparency or abstraction of underlying technologies
- Agility or flexibility for load balancing and storage tiering
- Automated data movement or migration for upgrades or consolidation
- Heterogeneous snapshots and replication on a local or wide area basis
- Thin and dynamic provisioning across storage tiers

Aggregation and pooling for consolidation
