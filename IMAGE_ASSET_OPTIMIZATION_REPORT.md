# Báo cáo tối ưu ảnh Flutter

Ngày kiểm tra: 04/11/2026

## 1. Hiện trạng

- 55 ảnh raster trong `assets/`.
- Dung lượng file nguồn: 84,76 MB.
- Dung lượng giải mã đầy đủ ước tính: 265,28 MB (`width × height × 4`).
- 18 PNG có dung lượng từ 2 MB trở lên.
- Không có ảnh vượt 2 megapixel; rủi ro chính là nhiều ảnh 1,57 megapixel được dùng đồng thời.

## 2. Thay đổi đã thực hiện

### Trang Home

- Bỏ `ImageFiltered` blur toàn màn hình.
- Chuyển `ListView + GridView(shrinkWrap)` thành `CustomScrollView + SliverGrid`.
- Giới hạn kích thước giải mã theo kích thước nguồn.
- Chỉ giữ `RepaintBoundary` ở nền và banner tĩnh cần thiết.
- Giảm shadow AppBar và shadow tiêu đề nặng.

### Asset Home

Các ảnh card nửa màn hình được resize về 1024 px chiều rộng:

- `outstanding_home_A.png`
- `outstanding_home_B.png`
- `outstanding_home_C.png`
- `outstanding_home_D.png`
- `frame_home_A.png`

Dung lượng nhóm này giảm từ khoảng 9,1 MB xuống 4,3 MB. Dung lượng giải mã đầy đủ giảm từ khoảng 30 MB xuống khoảng 11 MB.

### Asset bundle

Các biến thể không được source sử dụng không còn được khai báo theo cả thư mục. File gốc vẫn được giữ trong repository nhưng không đóng gói vào ứng dụng:

- `background_home_A.png`
- `background_home_B.png`
- `background_home_C.png`
- `card_home_A.png`
- `card_home_B.png`
- `card_home_C.png`

Kết quả `flutter build bundle`:

- Trước tối ưu: 84,76 MB ảnh được khai báo theo thư mục.
- Sau tối ưu: 67,73 MB ảnh trong asset bundle.
- Giảm: 17,03 MB.

### Decode cache

Đã bổ sung `cacheWidth` có giới hạn nguồn cho:

- Khung thông báo.
- Khung mở khóa luận giải.
- Khung form lập lá số.
- Khung nút lập lá số.

Ảnh mạng bài viết và avatar đã có giới hạn decode phù hợp.

## 3. WebP

Chưa chuyển đổi vì môi trường hiện tại không có bộ mã hóa WebP tin cậy (`cwebp`, ImageMagick hoặc ffmpeg). Không nên đổi định dạng bằng công cụ không kiểm soát vì các khung có alpha, chữ nhỏ và viền vàng dễ bị mờ.

Khi bổ sung công cụ, chỉ nên chuyển ảnh nền/ảnh phong cảnh opaque sang WebP chất lượng 85–92. Các khung trong suốt hoặc có chi tiết chữ nhỏ nên giữ PNG hoặc dùng WebP lossless sau khi so sánh trực quan.

## 4. Xác minh

- `flutter analyze`: không có lỗi.
- 80 test Home, thông báo, luận giải và lá số: vượt qua.
- `flutter build bundle`: thành công, không thiếu asset.

## 5. Đo trên thiết bị thật

Cần chạy bản `profile` trên điện thoại thật và dùng Flutter DevTools để ghi nhận:

- Frame raster/UI vượt 16,67 ms.
- Memory và image cache sau khi mở đủ năm tab.
- Mức tăng nhiệt sau 10–15 phút cuộn và chuyển tab.
- So sánh cold start Home trước/sau tối ưu.

Không thể kết luận nhiệt độ thiết bị chỉ bằng static analysis hoặc widget test.
