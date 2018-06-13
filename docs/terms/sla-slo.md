# SLA, SLO là gì
---
## Tổng quan về SLA
### Tổng quan
Thỏa thuận cấp độ dịch vụ (SLA) đơn giản là một tài liệu mô tả cấp độ dịch vụ mong đợi của khách hàng từ một nhà cung cấp, với các thước đo để đo lường dịch vụ; và các biện pháp khắc phục hoặc hình phạt, nếu có, khi cấp độ đã được thỏa thuận không thể đạt được. Thông thường, SLA là thỏa thuận giữa công ty và nhà cung cấp bên ngoài, nhưng cũng có thể là giữa hai phòng ban của một công ty.

Ví dụ SLA của một công ty viễn thông có thể cam kết mức độ khả dụng của mạng là 99,999% (tính ra mỗi năm khoảng 5 phút 25 giây mất mạng, dù tin hay không, thời gian này vẫn có thể là quá dài đối với một số ngành kinh doanh), và cũng cam kết sẽ giảm phần trăm cước phí thanh toán cho khách hàng nếu không đạt được mức cam kết trên, thông thường dựa trên một thang đối chiếu dựa trên mức độ ảnh hưởng của các vi phạm.

### Tại sao cần SLA?

SLA tập hợp thông tin về tất cả các dịch vụ được được kí kết trên hợp đồng và độ tin cậy kỳ vọng của họ vào một văn bản duy nhất. SLA nêu rõ thước đo, trách nhiệm và kỳ vọng để khi nảy sinh các vấn đề về dịch vụ, không bên nào có thể nói không biết. SLA đảm bảo cả hai bên đều hiểu về các yêu cầu giống nhau.

Bất kỳ hợp đồng có giá trị nào mà không có một SLA liên kết (được xem xét thông qua luật sư) có thể dễ dàng bị hiểu sai dù cố ý hay vô ý. SLA giúp bảo vệ cả hai bên trong hợp đồng.

### Ai cung cấp SLA?

Hầu hết nhà cung cấp dịch vụ có một bộ tiêu chuẩn cho SLA – đôi khi là các tiêu chuẩn riêng, phản ánh các mức độ dịch vụ khác nhau với mức giá khác nhau – đó có thể là một điểm khởi đầu tốt khi đàm phán. Những tiêu chuẩn này nên được xem xét và sửa đổi bởi cố vấn pháp lý của khách hàng, vì những tiêu chuẩn đó thường thiên về lợi ích của nhà cung cấp.

Khi gửi một đề nghị mời thầu (RFP – Request for Proposal), khách hàng nên ghi rõ các cấp độ dịch vụ kỳ vọng ​​như một phần của yêu cầu; điều này sẽ ảnh hưởng đến các dịch vụ cung cấp và giá cả và thậm chí có thể ảnh hưởng đến quyết định đáp ứng dịch vụ của nhà cung cấp. Ví dụ, nếu bạn yêu cầu mức độ sẵn sàng của một hệ thống là 99,999%, và các nhà cung cấp không thể đáp ứng yêu cầu này với thiết kế có sẵn của bạn, nhà cung cấp có thể đề xuất một giải pháp khác, tốt hơn.

### Các thành phần chính cấu thành một SLA?

SLA bao gồm các thành phần trong hai mảng: dịch vụ và quản lý.

Yếu tố dịch vụ bao gồm các chi tiết cụ thể về dịch vụ được cung cấp (và những gì không được cung cấp), điều kiện sẵn có của dịch vụ, các tiêu chuẩn cũng như khung thời gian cho mỗi cấp độ dịch vụ (ví dụ lượng thời gian chính và thời gian phụ có thể có cấp độ dịch vụ khác nhau), trách nhiệm của mỗi bên, thủ tục, và sự đánh đổi giữa chi phí và dịch vụ.

Yếu tố quản lý bao gồm các định nghĩa về tiêu chuẩn và phương pháp đo lường, quy trình báo cáo, nội dung và tần suất báo cáo, quá trình giải quyết tranh chấp, một điều khoản bồi thường để bảo vệ khách hàng do kiện cáo từ bên thứ ba do vi phạm cấp độ dịch vụ (điều này nên được ghi trong hợp đồng), và một cơ chế cập nhật thỏa thuận theo yêu cầu.

### Nguồn 
http://xaydungkpi.com/sla-la-gi-diem-khac-biet-giua-kpi-va-sla/

---

## Tổng quan về SLO
### Tổng quan
Service level objective (SLO) là các yếu tố cấu tạo service level agreement (SLA), điều khoản giữa nhà cung cấp dịch vụ và khách hàng. SLOs được thỏa thuận dự trên thang đo hiệu suất nhà cung cấp dịch vụ, tránh tranh chấp, hiểu lầm giữa các bên

Thường có nhầm lẫn giữa SLA và SLO. 
- SLA là thỏa thuận dịch vụ. 
- SLO là các đặc tính đo lương dựa trên SLA như tính sẵn sàng (availability), thông lượng (throughput), tần suất (frequency), thời gian phản hồi (response time), hoặc chất lượng (quality). 

> SLO cung cấp phương tiên đễ định lượng chất lượng dịch vụ

SLO có thể bao gồm nhiều phép đo lường dịch vụ (QoS)

### Nguồn
https://en.wikipedia.org/wiki/Service_level_objective