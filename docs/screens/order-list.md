# Danh sách Đơn hàng

**Route:** `/orders` (tab Orders)  
**Source:** `lib/features/order/presentation/order_list_screen.dart`

## Mục đích

Xem danh sách đơn bán (`sale.order`), tìm kiếm và lọc theo trạng thái.

## Tính năng

| Tính năng | Mô tả |
|-----------|--------|
| Tìm kiếm | Filter theo số đơn / khách hàng (`setQuery`). |
| Lọc trạng thái | Chip ngang scroll: All · Draft · Sent · Sales order · Cancelled — tap toggle. |
| Danh sách | `OrderCard` — số đơn, khách, amount, ngày, status chip; tap → detail. |
| Pull-to-refresh | `orderListController.refresh()`. |
| Empty / error | Tương tự Leads. |

**Đã có:** màn chi tiết `/orders/:id`, sửa `/orders/:id/edit` (draft/sent).

## Thiết kế UI

| Thành phần | Chi tiết |
|------------|----------|
| AppBar | Tiêu đề “Orders” |
| Search | Padding `md` |
| Filter chips | `StatusChip` horizontal `ListView`, height 40 — **khác Leads** (Leads dùng underline tabs) |
| Order card | Số đơn primary w600 · `OrderStatusChip` · tên KH · amount xanh success w700 · icon calendar + ngày tuyệt đối |

Màu chip filter: Draft `#6B6B7B`, Sent `#FFC107`, Sales order `#28A745`, Cancelled `#712B13`, All `#714B67`.

## Luồng dữ liệu

```
orderListControllerProvider
  → OrderRepository search_read sale.order
  → filter client theo status + query
```

## Trạng thái

| Trạng thái | UI |
|------------|-----|
| Loading / error / empty | `LoadingView` / `ErrorView` / `EmptyState` (icon shopping_bag) |
| Data | `ListView.builder` |

## Điều hướng

Tab index 2 bottom nav. Quick action “New order” trên Dashboard chỉ `go` tới tab này — **chưa có** flow tạo đơn mới.
