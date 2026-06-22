# Hồ sơ (Profile)

**Route:** `/profile` (tab Profile)  
**Source:** `lib/features/profile/presentation/profile_screen.dart`

## Mục đích

Hiển thị thông tin user đang đăng nhập; lối vào Cài đặt và đăng xuất.

## Tính năng

| Tính năng | Mô tả |
|-----------|--------|
| Thẻ user | Avatar chữ cái đầu, tên, công ty, email từ `authController.user`. |
| Cài đặt | ListTile → push `/settings`. |
| Đăng xuất | Dialog xác nhận → `logout()` → `/login`. |

## Thiết kế UI

| Thành phần | Chi tiết |
|------------|----------|
| AppBar | “Profile” |
| User card | `Card` padding `lg`, avatar radius 40, nền primary 12%, chữ 32px bold primary |
| Tên | `titleLarge` w700 |
| Menu | ListTile settings + chevron; divider; logout đỏ (`AppColors.danger`) |

**So với design.md:** Chưa có header greeting + notification bell như mockup dashboard/profile mở rộng.

## Luồng dữ liệu

Chỉ đọc session local (`AuthController`) — không RPC profile riêng.

## Trạng thái

Luôn hiển thị data từ session; field rỗng fallback `'User'` / chuỗi trống.

## Điều hướng

Tab index 3. Settings là route root overlay (không hiện bottom nav khi mở settings).
