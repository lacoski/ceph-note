# Các yếu tố quan trọng trong Storage
---
## Tổng quan
3 yếu tố quan trọng của Storage là

![](images/ceph-ilt-1.png)

`Latency` đo lường độ trễ của hệ thống, ở đây nó đại diện cho thời gian đáp ứng yêu cầu IO, độ trễ trung bình của 1 IO. Số liệu này đối với HDD thường được tính bằng millisecond, đối với SSD tính bằng microsecond. 

`IOPS` (I/O Per Second) tượng trưng cho số lượng hoạt động IO có thể diễn ra trong 1 giây. Số liệu IOP rất quan trọng trong các hệ thống lưu trữ, đặc biệt là số lượng và tính ngẫu nhiên. Khi đánh giá 1 thiết bị cần xem xét giá trị Mã IOPS, với kích cỡ, bản chất IO.

`Băng thông` (Bandwidth hoặc cũng được biết là throughput), giá trị đại diện cho khối lượng dữ liệu có thể xử lý trong 1 thời điểm - có thể hiểu cách khác, nó là lượng dữ liệu được truyền đến hệ thống mỗi giây. Số liệu được do thường tính theo đơn vị MB/s hoặc GB/s. IO Size có thể là 4KB, 8KB, 32KB, .. 


Throughput đơn giản là tích giá trình IOPS với IO size.
```
Throughput   =   IOPS   x   I/O size
```

VD:

```
VD: 2048 IOPS với 8k blocksize
Throughput = IOPS x IO size = 2048 * 8K = 16,384 KB/S

Giá trị Throughput tương đương 16 MB/S.
```

Latency cũng ảnh hướng tới hiệu năng, độ trệ hệ thống tăng khiến các tiến trình diễn ra chậm hơn. 

```
Latency   ∝   IOPS
```

Biểu thức trên thể hiện mối quan hệ trực tiếp dựa Latency với IOPS, độ trễ hệ thống sẽ tăng lên theo cấp số nhân khi dần tới điểm bão hòa.

![](images/ceph-ilt-2.png)

Biểu đồ trên thể hiện ảnh hưởng giữa Latency với IOPS. Thời gian đáp ứng sẽ tăng lên nhanh khi số IOPS tới giới hạn. 

Latency là khoảng thời gian thiết bị từ thời điểm giải quyết xong 1 request tới thời điểm sẵn sàng bắt đầu tiến trình đọc ghi. Đối với ổ đĩa quay, độ trễ bao gồm thời gian đầu đọc chuyến đến dữ liệu cần tìm và độ trễ quay, cả 2 vẫn đề đều xuất phát từ quá trình cơ học.

Quan hệ giữ IO Size và IOPS, nếu các IO Size có kích thước nhỏ chúng sẽ tận dụng được nhiều IOPS. Các IO request lớn đồng nghĩa với sử dụng ít IOPS.
> Cả 2 đều cho tốc độ đọc ghi giống nhau

```
IO size = 4 KB, IOPS = 29600 
4096 x 29600 = 121 MB/s

IO size = 32 KB, IOPS = 3700
32784 x 3700 = 121 MB/s (IO size x IOPS)
```

Các truy cập ngẫu nhiên sẽ giảm khối lượng IOPS sử dụng cũng như throughput.

Ví dụ, 29000 IOPS, IO Size = 32KB = 121 MB/S, nhưng đây là giá trị truy cập tuần bị. Đối với truy cập ngẫu nhiên, ta phải sử dụng IO size (random) theo công thức:
```
IO size (random) x IOPS = Throughput

VD:
IO Size (random) x 245 = 0,96 MB/s
```

Từ đó cùng 1 loại ổ đĩa, tốc độ đọc ghi từ 121 MB/s giảm xuống còn 1 MB/s. Đó cung là lý do tại sao throughput không phải tham số quan trọng nhất trong 1 số trường hợp.

Ổ đĩa quay có tham số Revolutions Per Minute or "RPM". Thể hiện số vòng quay mỗi giây. Thông số này sẽ kéo theo tham số `Rotational Delay`, gọi là độ trễ quay. Các loại ổ cứng có tốc độ quay khác nhau sẽ có giá trị trễ khác nhau:

![](images/ceph-ilt-4.png)


Cả 2 tham số IOPS và throughput đều quan trọng, tùy theo bài toán

Tham số IOPS có thể tách ra thành các vấn đề
- Tổng IOPS, Số IOPS của ổ = số IOPS đọc ghi liên tiếp + đọc ghi ngẫu nhiên. Đây là vấn đề được quan tâm trong thực tế
- IOPS đọc ngẫu nhiên với hiệu suất 100% (Số IOPS có thể sử dụng cho đọc ngẫu nhiên)
- IOPS ghi ngẫu nhiên với hiệu suất 100% (Số IOPS thực sự có thể sử dụng cho ghi ngẫu nhiên)
- IOPS đọc tuần tự với hiệt suất 100% (Số IOPS có thể sử dụng cho đọc tuần tự)
- IOPS ghi tuần tự với hiệt suất 100% (Số IOPS có thể sử dụng cho ghi tuần tự)

VD Trên tool test NFS

pic 5

Hoạt động IO thực hiện trên ổ theo quy trình:
- Bước 1: Controller sinh cmd IO tới ổ
- Bước 2: Đĩa và đầu đọc đọc và tìm kiếm vị trí IO. (Đây được gọi là quá trình tìm kiếm)
 - Dữ liệu tại thời điểm này vẫn chưa thể đọc, phải chờ tới thời điểm đầu đọc quay tới init data block (block khởi tạo). Việc này dẫn đến độ trẽ quay
- Bước 3: Dự liệu sau đó được đọc tuần tự tới khi hoàn thành quá trình đọc
 - Tiến trình này gọi là Data Transfer (quá trình truyền dữ liệu). Tiến trình này đi cùng với tham số Transfer time (Thời gian truyền). 

Sau 3 bước trên, hoàn tất quá trình IO.

Các nhà sản xuất ổ đĩa thường đặt các tham số này trên bìa sản phẩn, thường đặt dưới tên 
- Average addressing time: Thời gian dữ liệu có thể đọc hoặc ghi trên bất kỳ track, nằm tại bất kỳ đầu trên disk. 
- Disk rotation speed: Thời gian đĩa và đầu đọc tìm được đến vị trí bắt đầu của track chứa dữ liệu. 
- Maximum transmission speed: Cung cấp thời gian thời gian truyền tối đa, trong thực tế giá trị này sẽ rất khác, tùy theo từng IO Size sẽ có thời gian truyền khác nhau. Thời gian này bằng `IO Chunk Size / Max Transfer Rate`

> 3 tham số ứng với 3 bước trên

Công thức tính thười gian IO đơn:
```
IO Time = Seek Time + 60 sec/Rotational Speed/2 + IO Chunk Size/Transfer Rate
```

Tính toán IOPS
```
IOPS = 1/IO Time = 1/(Seek Time + 60 sec/Rotational Speed/2 + IO Chunk Size/Transfer Rate)
```

VD: Với hoạt động đọc ghi ngẫu nhiên
```
4K (1/7.1 ms = 140 IOPS) 
5ms + (60sec/15000RPM/2) + 4K/40MB = 5 + 2 + 0.1 = 7.1 

8k (1/7.2 ms = 139 IOPS) 
5ms + (60sec/15000RPM/2) + 8K/40MB = 5 + 2 + 0.2 = 7.2 

16K (1/7.4 ms = 135 IOPS) 
5ms + (60sec/15000RPM/2) + 16K/40MB = 5 + 2 + 0.4 = 7.4 

32K (1/7.8 ms = 128 IOPS) 
5ms + (60sec/15000RPM/2) + 32K/40MB = 5 + 2 + 0.8 = 7.8 

64K (1/8.6 ms = 116 IOPS) 
5ms + (60sec/15000RPM/2) + 64K/40MB = 5 + 2 + 1.6 = 8.6
```

VD: Đối với đọc ghi tuần tự
```
4K (1/0.1 ms = 10000 IOPS) 
0ms + 0ms + 4K/40MB = 0.1 

8k (1/0.2 ms = 5000 IOPS) 
0ms + 0ms + 8K/40MB = 0.22K 

(1/0.4 ms = 2500 IOPS) 
0ms + 0ms + 16K/40MB = 0.4 

32K (1/0.8 ms = 1250 IOPS) 
0ms + 0ms + 32K/40MB = 0.8 

64K (1/1.6 ms = 625 IOPS) 
0ms + 0ms + 64K/40MB = 1.6
```

Qua đó khi nói đến IOPS, nó sẽ nói tới khả năng IO của hệ thống. Số lượng IOPS sẽ khác nhau khi tính xét theo đọc ghi tuần tự và ngẫu nhiên. IOPS tùy thuộc vào size của IO block, số IOPS sử dụng cho các size IO block sẽ khác nhau. 

__IOPS trên SSD và HDD__

Xem thêm: https://en.wikipedia.org/wiki/IOPS


Các hoạt động IO:
- Large / small block I/O
- Continuous / random I/O
- Sequential / Concurrent I/O

## App tương tác với Storage
Các App tương tác với Storage

![](images/ceph-ilt-3.png)

`Latency` là hiệu năng ứng dụng. Nếu muốn cải thện trải nhiệm người dùng, muốn ứng dụng đọc dữ liệu nhanh hơn, .., độ trễ là rất quan trọng.

`IOPS` sẽ giúp giải quyết khối lượng công việc lớn nhanh hơn.

`Bandwidth / Throughput` đáp ứng khả năng truyền dữ liệu vào hệ thống. Đây là 1 vấn đề quan trọng trong các Data Center, nơi cần xử lý lưu trữ nhiều loại dữ liệu. Hoặc các DB tại mỗi thời điểm nào đó cần sử dụng băng thông đọc ghi rất lớn.

Trước đây, các giao dịch trực tuyến phụ thuộc rất nhiều vào thời gian phản hồi. Vì vậy các hệ thống có giá trị IOPS tốt sẽ xử lý các giao dịch trực tuyến nhanh. Nhưng đến hiện tại, vấn đề trở nên phức tạp hơn. 1 số cơ sở dữ liệu phụ thuộc vào việc truyền dữ liệu tuần tự (throughput), ảnh hưởng thời gian phản hồi IO đơn.

Mặt khác, high throughput góp phần quan trọng, đặc biệt khi nói đến khả năng truyền khối lượng lớn công việc tuần tự như truy vấn các file audio, video khối lượng lớn. Vì vậy, nếu throughput cao sẽ đáp ứng được khối lượng công việc cao hơn (càng nhiều MB/s càng xử lý được nhiều công việc)

# Nguồn

https://insightsblog.violinsystems.com/blog/the-fundamental-characteristics-of-storage

http://rickardnobel.se/storage-performance-iops-latency-throughput/

https://blog.csdn.net/hanchengxi/article/details/19089589

https://en.wikipedia.org/wiki/IOPS
