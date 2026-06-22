# Danh sách Lead

**Route:** `/leads` (tab Leads)  
**Source:** `lib/features/lead/presentation/lead_list_screen.dart`

## Mục đích

Duyệt, tìm kiếm và lọc lead CRM; điểm vào chi tiết từng bản ghi.

## Tính năng

| Tính năng | Mô tả |
|-----------|--------|
| Header + đếm | Tiêu đề “Leads” + `{n} total` (số item sau filter client). |
| Tìm kiếm | `SearchField` — filter theo query (`setQuery`). |
| Lọc stage | Tab underline: All · New · Qualified · **Proposition** · Won · Lost |
| Toggle type | Leads / Opportunities (`type` filter trên Odoo) |
| Sort | Popup: newest, oldest, name, revenue, priority |
| Pagination | Infinite scroll, 25 items/page |
| Pipeline | Icon Kanban → `/leads/pipeline` |
| List lines | Render `MobileUiListDisplay.lines()` từ layout Odoo |
| Danh sách card | `LeadCard` — tap → `/leads/:id`. |
| Server-driven list | Field hiển thị trên card lấy từ layout Odoo `crm.lead` / `list` (`MobileUiListDisplay`). |
| Pull-to-refresh | Reload từ Odoo `search_read`. |
| Empty / error | `EmptyState` / `ErrorView` khi không có dữ liệu hoặc lỗi mạng. |

## Thiết kế UI

| Thành phần | Chi tiết |
|------------|----------|
| Header | `headlineMedium` + count `titleMedium` muted w400 |
| Search | Padding ngang `md`, hint localized |
| Status tabs | Underline tabs (không dùng chip màu) — khớp design.md |
| Lead card | Avatar tròn 48px (initials, màu theo stage) · tên w600 · badge stage góc phải · company muted · phone icon + số · **relative time** (`AppFormatters.relative`) |
| Card container | `Card` + `InkWell`, margin bottom `md`, padding `md` |

Layout list field (primary/subtitle/lines) cấu hình trên Odoo **CRM → Configuration → Mobile App UI**.

## Luồng dữ liệu

```
leadListControllerProvider
  → LeadRepository._fetchRemote
  → loadListLayout() + search_read(fields từ layout)
  → map → LeadListItem(lead, values)
```

Filter stage và query áp dụng trên client sau khi fetch (hoặc trong controller — xem `lead_list_controller.dart`).

## Trạng thái

| Trạng thái | UI |
|------------|-----|
| Loading (list rỗng) | `LoadingView` |
| Error (list rỗng) | `ErrorView` + Retry |
| Empty | Icon people + message |
| Có data | `ListView.builder` + refresh |

## Điều hướng

Tab index 1. FAB giữa bottom bar cũng mở `/create-lead`.
