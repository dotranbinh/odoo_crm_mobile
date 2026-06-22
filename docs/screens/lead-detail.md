# Chi tiết Lead

**Route:** `/leads/:id`  
**Source:** `lib/features/lead/presentation/lead_detail_screen.dart`

## Mục đích

Xem thông tin lead, liên hệ nhanh, ghi chú và lịch sử hoạt động; mở form sửa.

## Tính năng

| Tính năng | Mô tả |
|-----------|--------|
| Hero header | Avatar initials, tên, công ty, badge stage. |
| Contact actions | Call (`tel:`) · Message (`sms:`) · Email (`mailto:`); long-press = copy |
| Tab Info | Sections read-only từ layout Odoo `detail` |
| Tab Notes | `LeadChatterCard` — log note, discussion, email |
| Tab Activity | Scheduled activities + tracking timeline; FAB schedule |
| CRM actions | Menu ⋯: Mark Won/Lost, Change stage, Assign, Convert |
| Sửa | Nút edit → `/leads/:id/edit`; pop `true` thì refresh |
| Pull-to-refresh | Refresh detail controller + chatter controller. |

## Thiết kế UI

| Thành phần | Chi tiết |
|------------|----------|
| Top bar | Back · label “Leads” center muted · edit icon |
| Hero avatar | 72×72 tròn, màu nền/chữ theo `LeadStageBadge` |
| Tên | `titleLarge` w600 center |
| Contact | 3× `_CircleAction` 48px — Call (nền won tint), Message/Email (surface tint) |
| Sub-tabs | Underline 2px primary khi active; labels: Info · Notes · Activity |
| Info sections | Card groups từ mobile UI schema, label ngoài field (`outsideLabel: true`) |

Khớp design.md § Lead detail (avatar centered, contact circles, underline tabs).

## Luồng dữ liệu

```
leadDetailControllerProvider(id)
  → LeadRepository: layout detail + read(fields)
  → LeadDetailViewData(summary, schema, values)

leadChatterControllerProvider(id)  // Notes + Activity tabs
  → mail.message search_read
```

Detail schema: ưu tiên layout Odoo; fallback `get_views` khi `AppConfig.mobileUiFallbackToFormXml`.

## Trạng thái

| Trạng thái | UI |
|------------|-----|
| Loading | AppBar + `LoadingView` |
| Error | AppBar + `ErrorView` + Retry |
| Notes empty | Icon notes + “No notes yet” |
| Activity empty | `_EmptyActivity` widget |

## Điều hướng

Nested trong branch Leads; back pop về list. Edit dùng **root navigator** (full-screen modal).
