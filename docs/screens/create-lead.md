# Tạo Lead mới

**Route:** `/create-lead`  
**Source:** `lib/features/create_lead/presentation/create_lead_screen.dart`

## Mục đích

Tạo bản ghi `crm.lead` mới — mở từ FAB bottom nav hoặc quick action Dashboard.

## Tính năng

| Tính năng | Mô tả |
|-----------|--------|
| Mobile UI form | Layout Odoo `create` (hoặc fallback `form`) → `MobileUiFormBuilder`. |
| Defaults | Tự gán: `priority = '1'`, `type = 'lead'`, `stage_id` = stage đầu danh sách. |
| Legacy fallback | Fields: customer name*, phone*, email, source dropdown, note. |
| Lưu (AppBar) | TextButton “Save” trên AppBar. |
| Lưu (body) | `PrimaryButton` + `OutlinedButton` Cancel. |
| Thành công | SnackBar + `context.pop()` (không navigate tới detail). |
| RPC | `createLeadController.saveValues()` → Odoo `create`. |

## Thiết kế UI

| Thành phần | Chi tiết |
|------------|----------|
| AppBar | Title “Create lead”, close leading, Save text action trailing |
| Body padding | `AppSizes.md` all sides |
| Form | Giống edit — sections server-driven hoặc legacy fields |
| Actions cuối | Primary Save + Outlined Cancel (legacy path có cả hai) |

## Luồng dữ liệu

```
loadCreateLayout() → LeadRepository.loadCreateLayout()
_applyCreateDefaults() trên mobile form
_onSave → buildCreateValuesFromMap + create RPC
```

## Trạng thái

| Trạng thái | UI |
|------------|-----|
| Layout loading | LoadingView |
| Saving | Disable close/Save, button spinner |

## Điều hướng

`parentNavigatorKey: root` — modal full screen từ FAB (`AppShell`) hoặc `context.push` từ Dashboard.
