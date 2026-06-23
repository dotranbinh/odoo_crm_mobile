# Chi tiết Đơn hàng

**Route:** `/orders/:id`  
**Source:** `lib/features/order/presentation/order_detail_screen.dart`

## Mục đích

Xem chi tiết `sale.order` — khách hàng, thông tin báo giá, sales, order lines và tổng tiền.

## Tính năng

| Tính năng | Mô tả |
|-----------|--------|
| Header | Số đơn, status chip, tên KH, tổng tiền |
| Sections | Customer · Quotation info · Sales · Note · Order lines |
| Edit | Nút **Edit** trên AppBar khi `state` là `draft` hoặc `sent` |
| Pull-to-refresh | `orderDetailController.refresh()` |
| RPC | `fetchOrderById` — đọc header + `sale.order.line` |

## Điều hướng

- Từ order list: tap card → `/orders/:id`
- Edit: `/orders/:id/edit` (root navigator, full screen)

## Trạng thái

| Trạng thái | UI |
|------------|-----|
| Loading | `LoadingView` |
| Error | `ErrorView` + retry |
| `sale` / `cancel` | Không hiện nút Edit |
