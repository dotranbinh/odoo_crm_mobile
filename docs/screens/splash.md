# Splash

**Route:** `/splash`  
**Source:** `lib/features/auth/presentation/splash_screen.dart`

## Mục đích

Màn hình khởi động — hiển thị thương hiệu app trong lúc khôi phục phiên đăng nhập và quyết định điều hướng tiếp theo.

## Tính năng

| Tính năng | Mô tả |
|-----------|--------|
| Khôi phục session | Gọi `authController.initialize()` để đọc session đã lưu (Odoo URL, DB, cookie/token). |
| Delay hiển thị | Chờ tối thiểu ~1,2 giây để tránh nhấp nháy khi session khôi phục nhanh. |
| Điều hướng tự động | Đã đăng nhập → `/dashboard`; chưa → `/login`. |
| Bảo vệ route | Router redirect: mọi route khác `/splash` bị chặn cho đến khi auth khởi tạo xong. |

## Thiết kế UI

| Thành phần | Chi tiết |
|------------|----------|
| Layout | `Scaffold` full-screen, nội dung căn giữa theo cột dọc. |
| Logo | Ô vuông bo góc 88×88, nền primary 12% opacity, icon `bubble_chart` 48px màu primary. |
| Tiêu đề | `appTitle` — headline medium, màu primary, weight 700. |
| Tagline | `appTagline` — body medium, màu mặc định theme. |
| Loading | `CircularProgressIndicator` màu primary, cách tagline `xxl`. |

**Lưu ý thiết kế:** Màn này chưa áp dụng đầy đủ design spec mới (`design.md`) — vẫn dùng icon Material và weight 700 cho tiêu đề.

## Luồng dữ liệu

```
initState → authController.initialize()
         → delay 1200ms
         → context.go(dashboard | login)
```

Không gọi API Odoo trực tiếp; chỉ đọc local session store.

## Trạng thái

Không có xử lý lỗi riêng trên UI — lỗi khôi phục session được xử lý trong `AuthController` (coi như chưa đăng nhập).
