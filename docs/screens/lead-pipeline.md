# Pipeline Kanban

**Route:** `/leads/pipeline`  
**Source:** `lib/features/lead/presentation/lead_pipeline_screen.dart`

## Mục đích

Xem pipeline CRM dạng Kanban — cột theo `crm.stage`, kéo-thả đổi stage.

## Tính năng

| Tính năng | Mô tả |
|-----------|--------|
| Cột theo stage | `fetchPipelineStages()` + group leads theo `stage_id` |
| Kéo-thả | `LongPressDraggable` + `DragTarget` → `changeStage(id, stageId)` |
| Tổng revenue | Mỗi cột hiển thị count + tổng `expected_revenue` |
| Toggle type | Leads / Opportunities |
| Chuyển list | Icon list → `/leads` |

## Điều hướng

Từ lead list: icon Kanban góc phải header.
