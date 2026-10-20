# Tử Vi AI 2026

Flutter application nền tảng cho trải nghiệm tử vi cao cấp trên Android và iOS.

## Kiến trúc

- Feature-first, Clean Architecture theo nhu cầu thực tế.
- Riverpod cho state, Dio cho REST API, GoRouter cho điều hướng.
- `core/` chứa hạ tầng, theme và Mystic Design System dùng chung.
- `features/` chia theo nghiệp vụ; chỉ thêm `data/` và `domain/` khi feature có logic thật.

## Chạy dự án

```bash
flutter pub get
flutter run
```

API production được dùng mặc định. Khi chạy backend local, truyền URL qua
`dart-define` để không hardcode cấu hình môi trường:

```bash
flutter run --dart-define=API_BASE_URL=http://10.0.2.2:1707/api
```

Đăng nhập Google trên Android/iOS cần OAuth Client ID được cấp từ cùng Google
Cloud project mà backend cho phép:

```bash
flutter run \
  --dart-define=GOOGLE_SERVER_CLIENT_ID=WEB_CLIENT_ID.apps.googleusercontent.com \
  --dart-define=GOOGLE_IOS_CLIENT_ID=IOS_CLIENT_ID.apps.googleusercontent.com
```

Android còn cần đăng ký package name và SHA-1/SHA-256; iOS cần đăng ký bundle
ID và URL scheme đảo ngược. Không commit Client Secret vào ứng dụng.

Bearer token được lưu bằng KeyStore/Keychain thông qua
`flutter_secure_storage`; không lưu token trong SharedPreferences.

## Hiệu năng hình ảnh

Artwork tĩnh dùng asset WebP/PNG/SVG phù hợp và được đăng ký tập trung. Ảnh CDN cần giải mã theo kích thước hiển thị và dùng disk cache. Không preload toàn bộ artwork khi khởi động.
