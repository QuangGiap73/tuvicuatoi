# Audit API Flutter Tử Vi AI 2026

Ngày audit: 03/11/2026  
Phạm vi: toàn bộ `lib/`, đối chiếu OpenAPI trực tiếp tại `https://tuvicuatoi.com/api/schema/?format=json`. Audit chỉ đọc, không thay đổi source Flutter.

## Kết quả tổng quan

| Chỉ số | Số lượng |
|---|---:|
| Tổng operation trong OpenAPI | **54** |
| Đã tích hợp và có luồng UI/controller sử dụng | **44** |
| Tích hợp một phần (có request nhưng thiếu bằng chứng khai thác contract) | **0** |
| Có datasource/repository nhưng chưa được gọi | **0** |
| Chưa tích hợp trên Mobile | **9** |
| Backend-only, Mobile không nên gọi | **1** |

Quy ước: một operation chỉ được tính “đã tích hợp” khi tìm được đủ request trong repository và caller ngoài repository. Model, nút bấm hoặc route đơn lẻ không được tính. Base URL được ghép bởi `Dio` tại `lib/core/network/dio_provider.dart:9-12` từ `AppConfig.apiBaseUrl` ở `lib/core/config/app_config.dart:2-5`; vì vậy `/auth/login/` trong source tương ứng `/api/auth/login/` trong OpenAPI.

## Bảng đối chiếu 54 operation

| # | Method + endpoint OpenAPI | Phân loại | Bằng chứng trong Flutter |
|---:|---|---|---|
| 1 | POST `/api/ai/chat/` | Đã tích hợp + UI | `AiChatRepository.sendMessage`, `lib/features/ai_chat/data/ai_chat_repository.dart:101-128`; gọi tại `ai_chat_controller.dart:223` |
| 2 | GET `/api/ai/history/` | Đã tích hợp + UI | `getHistory`, `ai_chat_repository.dart:41-51`; gọi tại `ai_chat_controller.dart:130` |
| 3 | POST `/api/ai/history/clear/` | Đã tích hợp + UI | `clearHistory`, `ai_chat_repository.dart:81-86`; gọi tại `ai_chat_controller.dart:305` và `chat_history_sheet.dart:178` |
| 4 | POST `/api/analytics/pageview/` | Đã tích hợp + màn bài viết | `ArticleRepository.recordPageView`, `lib/features/articles/data/article_repository.dart:56-64`; gọi tại `article_detail_page.dart:39` |
| 5 | GET `/api/articles/` | Đã tích hợp + UI | `getCatalog`, `article_repository.dart:20-49`; gọi tại `article_catalog_controller.dart:31` |
| 6 | POST `/api/auth/change-password/` | Đã tích hợp + UI | `ProfileRepository.changePassword`, `lib/features/profile/data/profile_repository.dart:82-90`; gọi tại `account_settings_controller.dart:20` và `account_settings_page.dart:620` |
| 7 | POST `/api/auth/forgot-password/` | Đã tích hợp + UI | `requestPasswordReset`, `lib/features/auth/data/auth_repository.dart:84-94`; gọi tại `forgot_password_controller.dart:16` |
| 8 | POST `/api/auth/google/` | Đã tích hợp + UI | `loginWithGoogle`, `auth_repository.dart:58-64`; gọi tại `auth_controller.dart:66`, UI tại `register_page.dart:208` |
| 9 | POST `/api/auth/login/` | Đã tích hợp + UI | `login`, `auth_repository.dart:18-27`; gọi tại `auth_controller.dart:29`, UI tại `login_page.dart:151` |
| 10 | POST `/api/auth/logout/` | Đã tích hợp + UI | `logout`, `auth_repository.dart:145-150`; gọi tại `auth_controller.dart:94`, UI tại `profile_page.dart:88` |
| 11 | GET `/api/auth/me/` | Đã tích hợp | `me`, `auth_repository.dart:70-78`; gọi khôi phục/cập nhật phiên tại `auth_controller.dart:16,76` |
| 12 | POST `/api/auth/profile/avatar/` | Đã tích hợp + UI | `uploadAvatar`, `profile_repository.dart:14-35`; gọi tại `avatar_update_controller.dart:46` |
| 13 | POST `/api/auth/profile/update/` | Đã tích hợp + UI | `updateProfile`, `profile_repository.dart:108-125`; gọi tại `profile_edit_controller.dart:23` |
| 14 | POST `/api/auth/record-question/` | **Chưa tích hợp** | Không có path/method trong `lib/`; inventory request chỉ nằm trong 9 repository liệt kê ở phần Phương pháp |
| 15 | POST `/api/auth/register/` | Đã tích hợp + UI | `register`, `auth_repository.dart:33-52`; gọi tại `auth_controller.dart:47`, UI tại `register_page.dart:200` |
| 16 | POST `/api/auth/reset-password/` | Đã tích hợp + UI | `resetPassword`, `auth_repository.dart:123-140`; gọi tại `forgot_password_controller.dart:58` |
| 17 | POST `/api/auth/verify-reset-code/` | Đã tích hợp + UI | `verifyPasswordResetCode`, `auth_repository.dart:100-117`; gọi tại `forgot_password_controller.dart:37` |
| 18 | POST `/api/auth/wallet/spend/` | **Chưa tích hợp** | Không có path/method trong `lib/`; luồng mở khóa hiện dùng `/charts/reading-unlocks/` tại `interpretation_repository.dart:217,256` |
| 19 | POST `/api/chart/generate` | Đã tích hợp + UI | `ChartRepository.generate`, `lib/features/horoscope/data/chart_repository.dart:15-27`; gọi tại `chart_generation_controller.dart:38`, UI `horoscope_page.dart:88` |
| 20 | GET `/api/charts/{chart_id}/` | Đã tích hợp + nhiều màn | `getChartDetail`, `chart_repository.dart:100-108`; gọi tại AI `ai_chat_controller.dart:96`, vận hạn `daily_fortune_controller.dart:179`, luận giải `interpretation_controller.dart:88` |
| 21 | DELETE `/api/charts/{chart_id}/delete/` | Đã tích hợp + UI | `deleteChart`, `chart_repository.dart:85-92`; gọi tại `my_charts_controller.dart:42` |
| 22 | GET `/api/charts/{chart_id}/interpretation/` | Đã tích hợp + UI | `getSavedInterpretation`, `lib/features/interpretation/data/interpretation_repository.dart:150-163`; gọi qua `interpretation_content_service.dart:32` |
| 23 | POST `/api/charts/calculate/` | **Chưa tích hợp** | Không có path/method trong `lib/`; Mobile hiện dùng `/chart/generate` |
| 24 | GET `/api/charts/my-charts/` | Đã tích hợp + nhiều màn | `getMyCharts`, `chart_repository.dart:66-78`; gọi tại `my_charts_controller.dart:25` và `daily_fortune_controller.dart:134` |
| 25 | GET `/api/charts/reading-sections/` | Đã tích hợp 35 mục + UI | `getCatalog/getSections`, `interpretation_repository.dart:68-106`; gọi tại `interpretation_controller.dart:195` và `palace_detail_controller.dart:90`; model đọc group/pricing/section tại `interpretation_models.dart:208-414` |
| 26 | GET `/api/charts/reading-unlocks/` | Đã tích hợp + UI | `getUnlocks`, `interpretation_repository.dart:124-137`; gọi tại `interpretation_controller.dart:255`, `reading_unlock_service.dart:44`, `palace_detail_controller.dart:92` |
| 27 | POST `/api/charts/reading-unlocks/` | Đã tích hợp mở Xu + UI | `unlock/unlockBundle`, `interpretation_repository.dart:209-269`; gọi tại `interpretation_controller.dart:597,735`, UI `interpretation_page.dart:205,387` |
| 28 | POST `/api/charts/save/` | Đã tích hợp + UI | `save`, `chart_repository.dart:40-57`; gọi tại `chart_generation_controller.dart:99` và `interpretation_controller.dart:503` |
| 29 | GET `/api/health` | **Chưa tích hợp** | Không có path/method trong `lib/`; đây là health check, không có màn Mobile hiện tại |
| 30 | POST `/api/luan/chuyen-de` | Đã tích hợp + UI | `getTopicInterpretation`, `interpretation_repository.dart:29-57`; gọi tại `topic_interpretation_provider.dart:12` |
| 31 | POST `/api/luan/cung` | Đã tích hợp + UI | `getPalaceRules`, `lib/features/palace_detail/data/palace_detail_repository.dart:18-39`; gọi tại `palace_detail_controller.dart:79` |
| 32 | POST `/api/luan/search` | **Chưa tích hợp** | Không có path/method trong `lib/`; không tìm thấy UI tìm kiếm luận giải |
| 33 | POST `/api/luan/tam-phuong` | Đã tích hợp + UI | `getTriadRules`, `palace_detail_repository.dart:48-70`; gọi tại `palace_detail_controller.dart:85` |
| 34 | POST `/api/luan/to-hop` | **Chưa tích hợp** | Không có path/method trong `lib/` |
| 35 | GET `/api/monetization/coin-packages/` | Đã tích hợp + UI nạp Xu | `getPackages`, `lib/features/wallet/data/wallet_repository.dart:45-50`; gọi tại `top_up_controller.dart:37` |
| 36 | POST `/api/monetization/create-order/` | Đã tích hợp + checkout | `createOrder`, `wallet_repository.dart:68-88`; gọi tại `top_up_controller.dart:71`, UI `coin_packages_page.dart:794-814` |
| 37 | POST `/api/monetization/earn-coins/checkin/` | Đã tích hợp + UI | `checkIn`, `wallet_repository.dart:155-156`; gọi tại `wallet_controller.dart:73`, UI `wallet_page.dart:930-931` |
| 38 | POST `/api/monetization/earn-coins/claim-mission/` | Đã tích hợp + UI | `claimMission`, `wallet_repository.dart:165-169`; gọi tại `wallet_controller.dart:91`, UI `wallet_page.dart:943` |
| 39 | GET `/api/monetization/earn-coins/info/` | Đã tích hợp + UI Ví Xu/nhiệm vụ | `getInfo`, `wallet_repository.dart:19-21`; gọi tại `wallet_controller.dart:60`; model tại `wallet_models.dart:75-126` |
| 40 | POST `/api/monetization/earn-coins/record-chart-creation/` | Đã tích hợp | `recordChartCreation`, `wallet_repository.dart:172-177`; gọi sau lập lá số tại `chart_generation_controller.dart:48` |
| 41 | POST `/api/monetization/earn-coins/record-mission-action/` | Đã tích hợp + UI | `recordMissionAction`, `wallet_repository.dart:180-186`; gọi tại `wallet_controller.dart:104`, UI `wallet_page.dart:976` |
| 42 | POST `/api/monetization/earn-coins/start-mission/` | Đã tích hợp + UI | `startMission`, `wallet_repository.dart:158-163`; gọi tại `wallet_controller.dart:82`, UI `wallet_page.dart:948` |
| 43 | GET `/api/monetization/feature-costs/` | **Chưa tích hợp** | Không có path/method trong `lib/`; giá luận giải hiện lấy từ catalog 35 mục (`interpretation_models.dart:272-414`) |
| 44 | GET `/api/monetization/my-orders/` | Đã tích hợp + UI | `getMyOrders`, `wallet_repository.dart:114-123`; gọi tại `payment_order_controller.dart:84` |
| 45 | GET `/api/monetization/orders/{order_id}/` | Đã tích hợp + theo dõi đơn | `getOrder`, `wallet_repository.dart:95-108`; gọi tại `payment_order_controller.dart:38` |
| 46 | GET `/api/monetization/packages/` | Đã tích hợp + UI VIP | `getMembershipPackages`, `wallet_repository.dart:55-63`; gọi tại `top_up_controller.dart:38` |
| 47 | POST `/api/monetization/payos/webhook/` | **Backend-only** | Không có trong `lib/`, đúng kiến trúc: PayOS gọi server; Flutter không được tự gọi webhook |
| 48 | GET `/api/monetization/pdf-backgrounds/` | **Chưa tích hợp** | Không có path/method trong `lib/`; tính năng tải PDF đã bị loại khỏi luồng Mobile hiện tại |
| 49 | POST `/api/monetization/pdf-backgrounds/{background_id}/unlock/` | **Chưa tích hợp** | Không có path/method trong `lib/`; không có UI mở khóa nền PDF |
| 50 | GET `/api/monetization/transactions/` | Đã tích hợp + UI | `getTransactions`, `wallet_repository.dart:24-40`; gọi phân trang tại `transaction_history_controller.dart:121` |
| 51 | POST `/api/monetization/vouchers/validate/` | Đã tích hợp + checkout | `validateVoucher`, `wallet_repository.dart:131-149`; gọi tại `top_up_controller.dart:99` |
| 52 | GET `/api/tuvi/daily-fortune` | Đã tích hợp + màn Vận Hạn | `getCalendar`, `lib/features/daily_fortune/data/daily_fortune_repository.dart:25-34`; gọi tại `daily_fortune_controller.dart:95,218` |
| 53 | POST `/api/tuvi/daily-fortune` | Đã tích hợp + lá số cá nhân | `getPersonalized`, `daily_fortune_repository.dart:38-53`; gọi khi có chart tại `daily_fortune_controller.dart:90` |
| 54 | POST `/api/tuvi/read` | Đã tích hợp + màn luận giải | `generate`, `interpretation_repository.dart:175-198`; gọi qua `interpretation_content_service.dart:19`, được controller luận giải sử dụng |

## Kiểm tra các nhóm backend mới

- **35 mục luận giải:** đã lấy catalog động, giá, nhóm và trạng thái mở khóa. OpenAPI mô tả đủ 35 mục; Mobile không hardcode danh sách làm nguồn chính (`interpretation_repository.dart:68-106`, `interpretation_models.dart:208-414`, `interpretation_controller.dart:195`).
- **Mở khóa Xu:** đã có mở một mục và bundle; UI chỉ cập nhật trạng thái sau response (`interpretation_repository.dart:209-269`, `interpretation_controller.dart:564-748`).
- **Vận Hạn Hôm Nay:** cả GET lịch chung và POST theo lá số đã nối; chart detail được tải trước khi POST (`daily_fortune_controller.dart:90-95,179`). Mapper đọc response tại `daily_fortune_mapper.dart:6-194`.
- **Ví Xu, nhiệm vụ, điểm danh:** info, giao dịch, check-in, start/claim/action và thưởng lập lá số đều có caller thực tế.
- **Bài viết:** danh sách, featured, categories và nội dung bài được lấy trong cùng response `/articles/`; pageview được ghi ở trang chi tiết.
- **Nạp Xu/VIP:** coin package, membership package, voucher, tạo đơn, kiểm tra đơn và lịch sử đơn đều đã nối.
- **Chat AI:** lịch sử, xóa lịch sử và SSE chat đều đã nối; request có chart data/focus palace và có `CancelToken`.

## Dữ liệu giả/hardcode

Không tìm thấy màn nghiệp vụ nào trong các nhóm API trên thay toàn bộ response bằng danh sách giả. Các dữ liệu cục bộ đáng chú ý nhưng không phải dữ liệu backend giả:

- Tin nhắn chào mừng AI: `lib/features/ai_chat/presentation/state/ai_chat_state.dart:62`; chỉ là empty-state trước lịch sử server.
- Danh sách gợi ý chủ đề chat: `lib/features/ai_chat/presentation/ai_chat_page.dart:769`; là shortcut UI, không thay response AI.
- Tên 12 cung dùng chọn focus: `lib/features/ai_chat/presentation/controllers/ai_chat_controller.dart:21`; metadata UI.
- Giờ sinh/giới tính của form lập lá số: `lib/features/horoscope/presentation/widgets/chart_birth_form_card.dart:25,158`; option nhập liệu, không phải kết quả luận giải.
- `FeaturePlaceholder` tồn tại ở `lib/features/shared/presentation/feature_placeholder.dart:8` nhưng không có caller trong `lib/`.

## API backend Mobile chưa tận dụng

Client-relevant nhưng chưa có request: `auth/record-question`, `auth/wallet/spend`, `charts/calculate`, `health`, `luan/search`, `luan/to-hop`, `monetization/feature-costs`, hai API `pdf-backgrounds`. Riêng `payos/webhook` không phải khoảng trống Mobile.

Hai API cần xác nhận với backend trước khi thêm:

- `/auth/wallet/spend/` có thể trùng trách nhiệm trừ Xu nguyên tử với `/charts/reading-unlocks/`; Mobile không nên gọi cả hai cho cùng một thao tác.
- `/charts/calculate/` có thể trùng `/chart/generate`; cần xác định endpoint chuẩn để tránh hai contract song song.

## Danh sách việc cần làm

### P0

1. Chốt endpoint chuẩn cho lập lá số: `/chart/generate` hay `/charts/calculate/`; hiện Mobile chỉ dùng endpoint đầu. Tránh tích hợp endpoint thứ hai nếu backend chỉ giữ vì tương thích ngược.
2. Chốt cơ chế trừ Xu: tiếp tục để `/charts/reading-unlocks/` giao dịch nguyên tử hay dùng `/auth/wallet/spend/`. Không gọi `spend` riêng trước `unlock`, vì có nguy cơ trừ tiền hai lần hoặc trừ tiền nhưng mở khóa thất bại.
3. Bổ sung contract/integration test cho 35 mục, unlock đơn/bundle và `/tuvi/read`; đây là luồng có tiền và dữ liệu lớn dù hiện đã tích hợp UI.

### P1

1. Tích hợp `/monetization/feature-costs/` nếu backend muốn mọi giá tính năng được điều khiển từ server; hiện giá luận giải có từ reading catalog nhưng các tính năng khác chưa có nguồn chung.
2. Tích hợp `/luan/search` nếu sản phẩm cần tra cứu nội dung luận giải; hiện không có request hoặc màn tìm kiếm.
3. Đánh giá `/luan/to-hop` và thêm vào trang chi tiết cung nếu dữ liệu tổ hợp sao đem lại nội dung khác `/luan/cung` và `/luan/tam-phuong`.
4. Quyết định có cần `/auth/record-question/` ngoài lịch sử Chat AI hay không; hiện chat đã có history riêng nhưng không ghi endpoint thống kê câu hỏi này.

### P2

1. Chỉ thêm `/api/health` nếu ứng dụng cần màn chẩn đoán/trạng thái dịch vụ; không cần gọi ở mỗi lần mở app.
2. Hai API PDF background chỉ nên tích hợp nếu khôi phục chức năng xuất/tải PDF.
3. Không tích hợp PayOS webhook vào Flutter.

## Phương pháp và giới hạn bằng chứng

- OpenAPI được đọc trực tiếp ngày audit: 52 path, 54 operation.
- Quét toàn bộ `lib/` cho `Dio`, HTTP verb, URL literal, URL động và helper `_get/_post`.
- Request thực tế chỉ xuất hiện trong: `auth_repository.dart`, `profile_repository.dart`, `ai_chat_repository.dart`, `article_repository.dart`, `chart_repository.dart`, `daily_fortune_repository.dart`, `palace_detail_repository.dart`, `interpretation_repository.dart`, `wallet_repository.dart`.
- Từng method repository được tìm caller ngoài thư mục data. Không có method request nào không có caller.
- “Chưa tích hợp” nghĩa là không tìm được request/path/method tương ứng trong toàn bộ `lib/`; không suy diễn từ sự tồn tại của model hoặc nút.
- Đây là static audit source và schema, không đăng nhập/chạy giao dịch thật; do đó không khẳng định backend runtime thành công, quyền user hay dữ liệu production.
