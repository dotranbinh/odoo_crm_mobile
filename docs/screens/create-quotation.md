# Tạo báo giá (Quotation)

**Route:** `/create-order` · `/create-order?leadId={id}`  
**Source:** `lib/features/order/presentation/create_quotation_screen.dart`

## Mục đích

Tạo `sale.order` trạng thái draft (báo giá) từ Lead/Opportunity hoặc form trống từ Dashboard. Gọi trực tiếp JSON-RPC Odoo — không dùng `action_new_quotation()`.

## Entry points

| Nguồn | Route |
|-------|--------|
| Lead detail → Actions | `/create-order?leadId={id}` |
| Dashboard → New Order | `/create-order` (không leadId) |

## Tính năng

| Tính năng | Mô tả |
|-----------|--------|
| Customer | Hiển thị partner từ lead; cảnh báo + nút **Create customer** nếu thiếu `partner_id`. Dashboard: search partner. |
| Quotation info | `date_order`, `validity_date`, `origin` (readonly từ lead), `client_order_ref`, `note`. |
| Sales | Dropdown `user_id`, `team_id`, `pricelist_id`, `payment_term_id`. |
| Order lines | `OrderLinesEditor` — thêm/xóa dòng, search product, qty, unit price, subtotal preview. |
| Submit | `createQuotation` → convert lead nếu cần → tạo partner nếu cần → `sale.order` create. |
| Thành công | SnackBar + `pop(orderId)`. |

## Luồng Odoo

```
fetchLeadForQuotation (nếu có leadId)
  → convert_opportunity (nếu type=lead)
  → res.partner create + crm.lead write (nếu thiếu partner)
  → sale.order create (header + order_line O2M)
```

## Payload tối thiểu

**Header:** `partner_id`, `opportunity_id`, `origin`, `date_order`, `validity_date`, `user_id`, `team_id`, marketing fields từ lead, `note`, `client_order_ref`, `pricelist_id`, `payment_term_id`.

**Lines:** `order_line: [(0, 0, {product_id, product_uom_qty, price_unit, name})]`

## Validation

- Partner bắt buộc (tạo từ lead hoặc chọn thủ công).
- Ít nhất 1 order line.

## Thiết kế UI

| Thành phần | Chi tiết |
|------------|----------|
| AppBar | Title “Create quotation”, close leading |
| Sections | Customer · Quotation info · Sales · Order lines |
| Footer | Primary “Create quotation” + tổng tiền preview |

## Trạng thái

| Trạng thái | UI |
|------------|-----|
| Loading lookups | `LoadingView` |
| Saving | Disable form, button spinner |
| Error | SnackBar |

## Phụ thuộc Odoo

Module `sale` + `sale_crm` phải được cài trên database (`dev1`).

## Chưa có (roadmap)

- Màn chi tiết order `/orders/:id`
- `action_confirm` trên mobile
- Mobile UI layout server-driven cho `sale.order`
