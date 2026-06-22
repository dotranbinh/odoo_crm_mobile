# Cài đặt (Settings)

**Route:** `/settings`  
**Source:** `lib/features/settings/presentation/settings_screen.dart`

## Mục đích

Quản lý thông tin tài khoản và tuỳ chọn app; đăng xuất nhanh.

## Tính năng

| Tính năng | Mô tả | Trạng thái |
|-----------|--------|------------|
| Thông tin tài khoản | Hiển thị tên, email, công ty | ✓ |
| Giao diện | ListTile “Appearance” — Light (default) | Placeholder (`onTap: {}`) |
| Ngôn ngữ | ListTile “Language” — English | Placeholder |
| Giới thiệu | Version app | Placeholder |
| Đăng xuất | Logout trực tiếp, không dialog | ✓ → `/login` |

**Khác Profile:** Settings logout **không** hỏi xác nhận; Profile có `AlertDialog`.

## Thiết kế UI

| Thành phần | Chi tiết |
|------------|----------|
| AppBar | “Settings” |
| Section label | “Account info” — `titleSmall` muted |
| ListTiles | Icon leading outline, divider giữa sections |
| Sign out | Icon + text màu danger |

Layout `ListView` đơn giản — chưa dùng card grouping như design system đầy đủ.

## Luồng dữ liệu

```
authController.user (read-only display)
logout → AuthController.logout() → clear session → go login
```

## Điều hướng

Push từ Profile (`context.push`). `parentNavigatorKey: root` — back pop về Profile.
