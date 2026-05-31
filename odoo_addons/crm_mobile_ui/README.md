# CRM Mobile UI (Odoo 17 addon)

Configure Flutter CRM mobile screens: **list**, **detail**, and **form** per model.

## Install on `tascort_dev_8`

1. Copy `crm_mobile_ui` into your Odoo `addons_path`.
2. Restart Odoo, update Apps list.
3. Install **CRM Mobile UI**.
4. Open **CRM → Configuration → Mobile App UI** and adjust layouts.
5. Assign **Mobile UI / Manager** to admins who edit layouts.
6. On a layout form, click **Open Designer** for drag-and-drop editing (sections & fields).

## Mobile API

Model: `mobile.ui.layout`  
Method: `get_mobile_layout(model_name, screen, company_id=None, lang=None)`

- `screen`: `list` | `detail` | `form` | `create`

## Visual designer (OWL)

Managers open **Open Designer** on a layout record. Drag fields from the palette into phone sections, reorder, and set widgets/flags in the properties panel. Saves via `save_designer_state(layout_id, state)`.
- Returns `{ version, model, screen, sections[], ... }`
- `version: 0` + empty `sections` → app falls back to `get_views` XML parser

### JSON-RPC example

```json
{
  "jsonrpc": "2.0",
  "method": "call",
  "params": {
    "service": "object",
    "method": "execute_kw",
    "args": [
      "tascort_dev_8",
      "<uid>",
      "<password>",
      "mobile.ui.layout",
      "get_mobile_layout",
      ["crm.lead", "detail"],
      {}
    ]
  },
  "id": 1
}
```

## Default data

On install, creates active layouts for `crm.lead` list, detail, and form with sensible default fields.

## Flutter integration (other models)

End-to-end recipe for new models (list / detail / form, repository pattern, mock assets, limits): [../../docs/mobile-ui-screens.md](../../docs/mobile-ui-screens.md).

Reference feature: `crm_app/lib/features/lead/`. Shared engine: `crm_app/lib/core/mobile_ui/`.
