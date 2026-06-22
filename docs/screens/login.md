# Đăng nhập (Sign in)

**Route:** `/login`  
**Source:** `lib/features/auth/presentation/login_screen.dart`  
**Design spec:** [design.md §8 — Sign in](../../design.md) · Mockup: `mockup.html#signin`

## Mục đích

Xác thực người dùng với server Odoo; cho phép cấu hình URL và database khi cần.

## Tính năng

| Tính năng | Mô tả |
|-----------|--------|
| Đăng nhập Odoo | Gửi URL, DB, username, password qua `authController.login()`. |
| Validation | Username và password bắt buộc; URL hợp lệ khi mở Server settings. |
| Hiện/ẩn mật khẩu | Icon eye toggle `obscureText`. |
| Server settings | Section thu gọn: Odoo URL + Database (mặc định từ `AppConfig`). |
| Face ID | Nút secondary — hiện SnackBar “chưa khả dụng” (placeholder). |
| Lỗi đăng nhập | Hiển thị message đỏ giữa form và nút Sign in. |
| Loading | Nút Sign in disabled + spinner trắng khi `auth.isLoading`. |
| Thành công | `context.go('/dashboard')`. |

## Thiết kế UI

| Token / thành phần | Giá trị |
|--------------------|---------|
| Padding ngang | `AppSizes.screenPaddingH` (18px) |
| Brand mark | 48×48, radius 14px, nền `#EEEDFE`, icon storefront 22px primary |
| Headline | “Welcome back” 20px w500 + subtitle 13px muted |
| Input row | Label 12px muted → container trắng, border 0.5px `#E5E1EA`, radius 12px, icon leading 16px |
| Nút Sign in | Filled primary, radius 14px, padding vertical 14px, text 16px w500 |
| Divider “or” | 12px muted giữa hai đường kẻ |
| Face ID | Outlined, nền trắng, icon fingerprint primary |

**Không có:** checkbox “Remember me” — session persist mặc định.

## Luồng dữ liệu

```
Form validate → AuthController.login(baseUrl, db, login, password)
             → Odoo JSON-RPC authenticate
             → lưu session local
             → redirect dashboard
```

## Trạng thái

| Trạng thái | UI |
|------------|-----|
| Idle | Form đầy đủ, nút enabled |
| Loading | Nút Sign in spinner |
| Lỗi | Text đỏ `auth.error` |
| Đã login (redirect) | Router đẩy về dashboard nếu vào `/login` khi đã auth |
