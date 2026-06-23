# Sửa Đơn hàng

**Route:** `/orders/:id/edit`  
**Source:** `lib/features/order/presentation/edit_order_screen.dart`

## Mục đích

Cập nhật quotation / sales order (`sale.order` `write`) khi trạng thái còn cho phép sửa.

## Tính năng

| Tính năng | Mô tả |
|-----------|--------|
| Chỉnh sửa | Customer, validity date, client ref, note, sales fields, order lines |
| Order lines | `OrderLinesEditor` — thêm/sửa/xóa dòng (O2M commands `0,0` / `1,id` / `2,id`) |
| Lưu | `editOrderController.submit()` → `OrderRepository.updateOrder` |
| Thành công | SnackBar + `pop(true)` → detail refresh |

## Validation

- Partner bắt buộc
- Ít nhất 1 order line
- Chỉ load được khi `order.isEditable` (`draft` / `sent`)

## RPC

```
sale.order write (header)
order_line: [(1, lineId, vals), (0, 0, vals), (2, lineId)]
```

## Thiết kế UI

Giống màn **Create quotation** — sections Customer, Quotation info, Sales, Order lines, nút Save.
