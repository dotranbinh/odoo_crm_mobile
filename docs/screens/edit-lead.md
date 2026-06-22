# Sửa Lead

**Route:** `/leads/:id/edit`  
**Source:** `lib/features/lead/presentation/edit_lead_screen.dart`

## Mục đích

Cập nhật bản ghi `crm.lead` trên Odoo — form động theo layout server hoặc form legacy cố định.

## Tính năng

| Tính năng | Mô tả |
|-----------|--------|
| Mobile UI form | Khi layout Odoo `form` configured → `MobileUiFormBuilder` theo sections/fields. |
| Legacy fallback | Form hardcoded (contact, sales, stage, priority, revenue, deadline, note) khi layout trống. |
| Many2one | Search RPC qua `OdooRelationSearchService`; `stage_id` dropdown tĩnh từ `fetchLeadStages()`. |
| Tags | `tag_ids` — multi-select nếu layout có widget `tags`. |
| Validation | Legacy: required name/phone, email format; mobile form theo field renderer. |
| Lưu | `editLeadController.saveValues()` hoặc `save(LeadUpdateInput)` → Odoo `write`. |
| Hủy | Nút close AppBar → `context.pop()` không lưu. |
| Thành công | SnackBar “Lead updated” + `pop(true)` để detail refresh. |

## Thiết kế UI

| Thành phần | Chi tiết |
|------------|----------|
| AppBar | Title “Edit lead”, leading `Icons.close` |
| Body | `SingleChildScrollView`, padding ngang `screenPaddingH` |
| Mobile form | Sections từ Odoo — field renderer theo type/widget |
| Legacy form | `_SectionLabel` muted + `TextFormField` Material standard |
| Save | `PrimaryButton` full width cuối form |

Form **create** và **edit** dùng chung core `lib/core/mobile_ui/` — xem [mobile-ui-screens.md](../mobile-ui-screens.md).

## Luồng dữ liệu

```
initState → loadFormLayout() + fetchLeadStages() + fetchCrmTags()
editLeadViewControllerProvider(id) → read record (fields từ form layout)
_onSave → MobileUiWriteCoercer + write RPC
```

## Trạng thái

| Trạng thái | UI |
|------------|-----|
| Layout loading | AppBar + LoadingView |
| Record loading/error | AsyncWhen loading/error |
| Saving | PrimaryButton spinner, close disabled |

## Điều hướng

Route con của lead detail; `parentNavigatorKey: root` — hiển thị phủ full màn hình, không có bottom nav.
