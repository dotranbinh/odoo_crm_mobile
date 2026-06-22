# Dashboard

**Route:** `/dashboard` (tab Home)  
**Source:** `lib/features/dashboard/presentation/dashboard_screen.dart`

## Mục đích

Tổng quan CRM sau đăng nhập: giá trị pipeline, thống kê gọn, hành động nhanh, hoạt động gần đây — dữ liệu từ Odoo (`crm.lead`, `sale.order`).

## Tính năng

| Tính năng | Mô tả |
|-----------|--------|
| Header | Avatar + lời chào theo giờ (Good morning/afternoon/evening) + chuông thông báo (placeholder). |
| Pipeline hero | Tổng `expected_revenue` (trừ stage Lost) + thanh composition New/Qualified/Won + legend. |
| Stats strip | Một card 3 cột: Total leads · New leads · Orders (divider dọc). |
| Quick actions | 3 nút tròn: New lead · New order · Search — sát stats strip. |
| Recent activities | Timeline dot + line; lead/order gần nhất từ Odoo. |
| Pull-to-refresh | Reload metrics + activities. |

## Thiết kế UI

Khớp [design.md § Dashboard](../../design.md): không AppBar; padding ngang 18px; card viền 0.5px `#E5E1EA`, radius 16px; typography w400/w500 (không bold 700).

## Luồng dữ liệu

```
dashboardControllerProvider
  → DashboardRepository.fetchDashboard()
  → read_group(crm.lead) + search_count + search_read (activities)
```

Mock khi `AppConfig.useRealApi = false`.

## Trạng thái

| Trạng thái | UI |
|------------|-----|
| Loading | `LoadingView` |
| Error | `ErrorView` + Retry |
| Data | ListView scroll + refresh |

## Điều hướng

Tab index 0 bottom nav.
