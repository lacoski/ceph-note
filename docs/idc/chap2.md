# Cloud and Virtual Data Storage Networking

## Getting Started
Ta sử dụng chúng mỗi ngày nhưng lại không hiễu rõ nó. VD, khi không gian lưu trữ tới giới hạn, ta không thể tìm thêm không gian lưu trữ hoặc khi xảy ra thảm họa (cháy, lụt, virus, hỏng hóc) khi ta nhận ra dữ liệu chưa đượ backup, được bảo vệ. Chí phí cũng là 1 vấn đề, khi dữ liệu tăng lên từng ngày => chi phí bỏ ra cho việc lưu trữ tăng lên.

Đặc biệt, ta đang sống trong kỹ nguyên thông tin, luỗng dữ liễu mỗi năm đều nhảy vọt là không có giảm xuống.

Rất nhiều tài nguồn cần có để hỗ trợ cho information services, bao gồm app, ứng dụng quản lý. Quan trọng không kém là IO, Networking giữa server và data storage, các nhiệm vụ infrastructure resource management, tiến trình, ...


# Server and Storage I/O Fundamentals
Server, cũng đc gọi là các computer, đóng vài trò quan trọng trong cloud, ảo hóa, data storage networking. Về cơ bản, server sẽ chạy các ứng dụng các chương trình hỗ trợ, cung cấp các information service. Các chương trình này chịu trách nhiệm tạo các IO data, các truy cập network. 1 vài trò khác của server trong cloud và virtualized data centers là lưu trữ dữ liệu, thực hiện các nhiệm vụ với mục đích lưu trữ.

Server có nhiều loại, giá, hiệu năng, availability, capacity, and energy consumption, sự đa dạng của chúng hướng tới giải quyết các vấn đề khác nhau trong cloud. 1 loại khác của server là virtual server, khi chúng là các hypervisor vd Microsoft Hyper-V, VMware vSphere, or Citrix Xen .... chúng sử dụng để tạo các VM từ physical machines. Cloud-based compute or server resources được chia sẻ cho các VM.

Sự đa dạng computer or server tập trung vào các đối tượng khác nhau (office, business, enterprise, ...) chúng sẽ giải quyết các vấn đề khác nhau.

# General categories of servers and computers include:
- Laptops, desktops, and workstations
- Small floor-standing towers or rack-mounted 1U and 2U servers
- Medium-sized floor-standing towers or larger rack-mounted servers
- Blade centers and blade systems
- Large-sized floor-standing servers, including mainframes
- Specialized fault-tolerant, rugged, and embedded processing or real-time servers
- Physical and virtual along with cloud-based servers

Server có nhiều tên khác nhau: email server, database server, application server, Web server, video or file server, network server, security server, backup server, or storage server, dựa trên trách nhiệm của chúng.
