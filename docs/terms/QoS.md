# Quality of service (QoS)
---
## Tổng quan
Chất lượng dịch vụ - Quality of service (QOS) – là một chỉ số đo lường chất lương dịch vụ theo điều khoản SLO để từ đó xác định SLA.

## QoS được đánh giá dựa trên các tham số
- Độ sẵn sàng của dịch vụ
- Độ trễ (delay).
- Độ biến động trễ (jitter)
- Thông lượng hay băng thông
- Tỷ lệ tổn thất gói (packet loss rate): tỷ lệ các gói bị mất, bị hủy, và bị lỗi khi đi trong mạng.

## Ý nghĩa tham số
- Độ trễ end to end (Latency): Là thời gian cần thiết để gói tin đi từ source đến destination, trong suốt với các node trung gian (tức là ta không quan tâm thời gian đến tại các node trung gian. Bạn nên phân biệt delay và latency nhé. Delay là trong trễ để packet đi từ node này đến node kia trực tiếp. VD: nếu gói đi từ node 1 đến node 2 trực tiếp hết 10s thì ta nói nó là độ delay là 10s. Sau đó gói đi qua node 2, node 3.... node n. hết tổng cộng 100s thì lúc này ta nói nó là độ latency = 100s) OK ! latency là end to end delay. Delay/latency phụ thuộc vào khoảng cách, tốc độ truyền dữ liệu, và thời gian xử lý của các node mạng. 

- Độ jitter (Delay Variation: Jitter là sự biến động về độ trễ khi ta gửi các gói từ source đến destination. Chẳng hạn, source ta phát đi cứ 10ms một gói, thì nếu đường truyền là lý tưởng thì đầu thu sẽ nhận được gói sau trễ hơn gói trước 10ms, nhưng vì một lý do nào đó (chẳng hạn, do gói đi vào các hàng đợi của router, gói đi theo 1 đường khác…v.v) mà làm cho thời gian đến của gói sau so với gói trước có thể lớn hơn hoặc nhỏ hơn 10ms. Giá trị jitter sẽ là dương nếu gói sau đến chậm hơn gói trước 10ms (VD: nếu gói 1 nhận được ở thời điểm t0=100 và gói 2 nhận được ở t1=112, như vây độ delay sẽ là 12ms và độ jitter sẽ là 2ms. Và nếu gói tiếp theo nhận ở t2=120, thì như vậy độ delay của gói đó là 8ms, và độ jitter là -2ms). Đối với các ứng dụng như VoIP thì người ta không hề mong muốn giá trị Jitter là dương, và giá trị lý tưởng tất nhiên là 0. 

- Độ rớt gói, mất gói Packet loss

- Bandwidth và Throughput: Bandwidth là khả năng truyền dữ liệu đi trên 1 link có đơn vị là Kbps, Mbps, Gbps. bandwidth chỉ ra maximum capacity of theoretical transmission on a connection. Trong khi Throughput là số lượng data traffic đi qua 1 node trong một khoảng thời gian nhất định thông thường tính theo s. 

- Network Availability : độ sẵn sàng của mạng

## Nguồn 
http://www.pcworld.com.vn/articles/cong-nghe/cong-nghe/2005/09/1184451/quality-of-service/


https://vntelecom.org/diendan/showthread.php?t=9287

http://www.vnpro.org/forum/forum/ccnp%C2%AE-v%C3%A0-ccdp%C2%AE/tshoot/29998-t%E1%BB%95ng-quan-v%C3%AA-ch%E1%BA%A5t-l%C6%B0%E1%BB%A3ng-d%E1%BB%8Bch-v%E1%BB%A5-qos

