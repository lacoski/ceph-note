# Cloud and Virtual Data Storage Networking

## Getting Started
Ta sử dụng chúng mỗi ngày nhưng lại không hiễu rõ nó. VD, khi không gian lưu trữ tới giới hạn, ta không thể tìm thêm không gian lưu trữ hoặc khi xảy ra thảm họa (cháy, lụt, virus, hỏng hóc) khi ta nhận ra dữ liệu chưa đượ backup, được bảo vệ. Chí phí cũng là 1 vấn đề, khi dữ liệu tăng lên từng ngày => chi phí bỏ ra cho việc lưu trữ tăng lên.

Đặc biệt, ta đang sống trong kỹ nguyên thông tin, luỗng dữ liễu mỗi năm đều nhảy vọt là không có giảm xuống.

Rất nhiều tài nguồn cần có để hỗ trợ cho information services, bao gồm app, ứng dụng quản lý. Quan trọng không kém là IO, Networking giữa server và data storage, các nhiệm vụ infrastructure resource management, tiến trình, ...


# Server and Storage I/O Fundamentals
Server, cũng đc gọi là các computer, đóng vài trò quan trọng trong cloud, ảo hóa, data storage networking. Về cơ bản, server sẽ chạy các ứng dụng các chương trình hỗ trợ, cung cấp các information service. Các chương trình này chịu trách nhiệm tạo các IO data, các truy cập network. 1 vài trò khác của server trong cloud và virtualized data centers là lưu trữ dữ liệu, thực hiện các nhiệm vụ với mục đích lưu trữ.

Server có nhiều loại, giá, hiệu năng, availability, capacity, and energy consumption, sự đa dạng của chúng hướng tới giải quyết các vấn đề khác nhau trong cloud. 1 loại khác của server là virtual server, khi chúng là các hypervisor vd Microsoft Hyper-V, VMware vSphere, or Citrix Xen .... chúng sử dụng để tạo các VM từ physical machines. Cloud-based compute or server resources được chia sẻ cho các VM.

Sự đa dạng computer or server tập trung vào các đối tượng khác nhau (office, business, enterprise, ...) chúng sẽ giải quyết các vấn đề khác nhau.

## General categories of servers and computers include:
- Laptops, desktops, and workstations
- Small floor-standing towers or rack-mounted 1U and 2U servers
- Medium-sized floor-standing towers or larger rack-mounted servers
- Blade centers and blade systems
- Large-sized floor-standing servers, including mainframes
- Specialized fault-tolerant, rugged, and embedded processing or real-time servers
- Physical and virtual along with cloud-based servers

Server có nhiều tên khác nhau: email server, database server, application server, Web server, video or file server, network server, security server, backup server, or storage server, dựa trên trách nhiệm của chúng. Đây cũng là điều gây lẫn về server => vì 1 server có thể hỗ trợ nhiều dịch vụ khác nhau vì vậy ta nên cân nhắc server dạng storage, server hoặc 1 phần của network, hoặc app platform. Đôi khi thuật ngữ “appliance” được sử dụng cho server (loại server riêng biệt) khi dịch vụ được kết hợp cả hardware và software.

Về mặt kỹ thuật đây không phải 1 loại server, 1 số nhà sản xuất sử dụng thuật ngữ “tin-wrapped” software để tránh sự nhẫm lẫn appliance, server 

1 sự phát triển của "tin-wrapped software model" là software-wrapped appliance hoặc virtual appliance. Dưới model, các nhà cung cấp sử dụng VM để host software của họ trên cùng server physical, hoặc các appliance sử dụng cho nhưng mục đích riêng.VD: nhà cung cấp DB cung cấp các VM chạy sẵn sản phẩm của họ trên cùng Physical server. Giải pháp này tối ưu tài nguyên server nhưng vấn đề  sẽ xuất hiện khi các VM chạy quá mức ảnh hưởng tái các VM còn lại. Vấn đề này trở nên nghiêm trọng khi các VM đang trong giải đoạn nhạy cảm (backup, IO, ..)

> Keep in mind that cloud, virtual, and tin-wrapped servers or software still need physical compute, memory, I/O, networking, and storage resources.

# Server and I/O Architectures
Về cơ bản, các nhà cung cấp sẽ có nhưng kiến trúc khác nhau. Kiến trúc bao gồm CPU, Memory, internal busses or communication chips, and I/O port, tương tác giữa các port giữa kiến trúc đó với network, storage device, ... Computer cần thực hiện hoạt động IO trên các thiết bị khác nhau, và thành phần quan trọng để thực hiện quá trình IO và networking connectivity là Peripheral Component Interconnect (PCI) standard interface.

PCI là chuẩn chipset sử dụng cho kết nối giữa CPU và Memory với các thiết bị IO, các thiết bị mở rộng. Có rất nhiều chuẩn PCI định nghĩa bởi PCI Special Interest Group (PCISIG): PCI Express (PCIe), PCIx, Fibre Channel, Fibre Channel over Ethernet (FCoE), InfiniBand Architecture (IBA), SAS, SATA, Universal Serial Bus (USB), and 1394 Firewire. 

pic 1

pic 2

Các thành phần cơ bản trên server:
- Compute or CPU chips or sockets
- One or more cores per CPU socket or chips capable of single or multithreading
- Internal communication and I/O buses for connecting components
- Some main memory, commonly dynamic random access memory (DRAM)
- Optional sockets for expansion memory, extra CPUs, and I/O expansion slots
- Attachment for keyboards, video, and monitors (KVM)
- I/O connectivity for attachment of peripherals including networks and storage
- I/O networking connectivity ports and expansion slots such as PCIe
- Optional internal disk storage and expansion slots for external storage
- Power supplies and cooling fans

Dựa trên giá tiền, và các giải pháp khác nhau, các computer sẽ có số lượng Core, tốc độ xử lý, RAM, khe mở rộng (PCI) khác nhau. 

# Storage Hierarchy
kiến trúc storage liên quan từ memory tới các thiết bị mở rộng, bảo gồm tài nguyên ảo, cloud. Server cần IO networking để kiên kết server khác, truy cập theo các pp khác nhau (local, remote, cloud storage resources).

Tốc độ truy cập tới các thành phần L1, L2, trên CPU sẽ có tốc độ khác nhau (từ nhanh tới chậm, đố lớn khác nhau). Nhanh nhất => đi cùng với giá thành cao, kém linh hoạt. Chậm => độ lớn nhiều, giá thành vừa phải, độ linh hoạt cao (ứng với memory ~ các thiết bị storage). 

pic 3

Điều quan trọng là VM cần memory, bộ nhớ mở rộng có sẵn để hoạt động (tài nguyên lấy từ server vật lý) => VM đc coi là thành phần phần ảo, sử dụng cấu trúc dữ liệu riêng, truy cấp tài nguyên memory có sẵn. Càng nhiều VMs > cần nhiều Memory.

Các ứng dụng sẽ đòi hỏi các tài nguyên khác nhau, VD: db, video render, phân tích thông số, .... 

Các loại Storage có thể phân loại (NVRAM, FLASH base) hiêu năng sẽ khác nhau => giá thành khác nhau.

(các loại hdd, ssd, rpm, raid tài liệu tìm hiểu khóa luận trước)

# Disk Storage Fundamentals

Storage can be dedicated internal Direct Attached Storage (DAS) or external shared DAS in addition to being networked and shared on a local or remote or cloud basis.

pic 4

Các vấn đề yêu cầu I/O target vào vấn đề về block, file, object. Các chuẩn (e.g., SAS, iSCSI, Fibre Channel, FCoE, or SRP on InfiniBand), where the target is a SCSI logical unit (LUN).

pic 5

Các vấn đề về ổ đĩa, ....

pic 6

# Block Storage Access

trang 33 (33/48)