# Odoo CRM Mobile

Enterprise Flutter skeleton for Odoo CRM — feature-first architecture, JSON-RPC integration, modern UI.

**Odoo server (local):** [http://localhost:8069](http://localhost:8069)  
**Database:** `dev1` (from [crm_odoo_mobile/docker-compose.yml](../crm_odoo/crm_odoo_mobile/docker-compose.yml))

Override at build time: `--dart-define=ODOO_URL=... --dart-define=ODOO_DB=...`

## Tech stack

- Flutter · Riverpod · go_router · Dio · freezed · intl

## Getting started

```bash
flutter pub get
flutter gen-l10n          # lib/l10n/app_localizations.dart
dart run build_runner build
flutter run
```

## Real Odoo API vs mock

Edit [lib/app/constants/app_config.dart](lib/app/constants/app_config.dart):

```dart
static const bool useRealApi = true;   // live Odoo login + leads
static const bool autoLoginMock = false;
```

| `useRealApi` | `autoLoginMock` | Behavior |
|--------------|-----------------|----------|
| `true` | `false` | Login screen → Odoo authenticate → leads from `crm.lead` |
| `false` | `true` | Skip login with demo user + mock data |
| `false` | `false` | Login screen → mock auth |

## Login (real API)

1. Open app → Splash → **Login**
2. Fields are prefilled:
   - URL: `http://localhost:8069` (on Android emulator this is rewritten to `http://10.0.2.2:8069`)
   - Database: `dev1`
3. Enter Odoo credentials (e.g. `admin` / your password)
4. Tap **Login** → Dashboard → **Leads** uses layouts from addon **`crm_mobile_ui`** (Odoo menu: **CRM → Configuration → Mobile App UI**)

## Run on Web (Chrome) — CORS

On **Flutter Web**, the app calls Odoo `/jsonrpc` from a different port (e.g. `localhost:5xxxx` → `localhost:8069`). The browser blocks this unless Odoo sends CORS headers.

**Recommended (local Docker):** upgrade addon **CRM Mobile UI** — it enables `cors='*'` on `/jsonrpc` and web session routes:

```bash
cd crm_odoo/crm_odoo_mobile
docker compose exec odoo odoo -u crm_mobile_ui -d dev1 --stop-after-init
docker compose restart odoo
```

**Fallback (Chrome only, dev):**

```bash
flutter run -d chrome \
  --web-browser-flag="--disable-web-security" \
  --web-browser-flag="--user-data-dir=/tmp/chrome_cors_dev"
```

After a full page reload / hot restart, **sign in again** (password is kept in memory only on Web).

**Mobile/Desktop** uses `/web/session/authenticate` with cookies (no CORS issue).

## Run on mobile (iOS / Android)

No CORS issue — direct connection:

```bash
flutter run -d <device_id>
```

## Project structure

```
lib/
├── app/           # theme, router, AppConfig
├── core/          # Odoo JSON-RPC, Dio, widgets
├── features/      # auth, dashboard, lead, order, ...
└── l10n/
```

## Odoo JSON-RPC endpoints

| Endpoint | Purpose |
|----------|---------|
| `POST /web/session/authenticate` | Login |
| `POST /web/dataset/call_kw` | `crm.lead` `search_read`, `read`, `write`, `get_views` |
| `POST /web/session/destroy` | Logout |

## Mobile UI config (Odoo addon + Flutter)

When `useMobileUiConfig = true` in [lib/app/constants/app_config.dart](lib/app/constants/app_config.dart), the app loads layouts from the Odoo addon **`crm_mobile_ui`** via `mobile.ui.layout.get_mobile_layout` for **list**, **detail**, **form (edit)**, and **create** on `crm.lead`. If no active layout is returned (`version: 0`), detail falls back to `get_views` when `mobileUiFallbackToFormXml = true`; create falls back to the `form` layout, then a small legacy form.

| Flag | Default | Meaning |
|------|---------|---------|
| `useMobileUiConfig` | `true` | Prefer server mobile layout |
| `mobileUiFallbackToFormXml` | `true` | Use `get_views` when addon/layout missing |

Flutter: `lib/core/mobile_ui/` (config service, schema, mapper, form builder, list card display). Mock assets: `assets/mock/mobile_ui_crm_lead_{list,detail,form,create}.json`.

### Local Odoo (`crm_odoo_mobile`)

1. Start stack: `docker compose up` in `crm_odoo/crm_odoo_mobile`.
2. Install addon **CRM Mobile UI** (`crm_mobile_ui`) — already mounted at `custom-addons/crm_mobile_ui`.
3. Open **CRM → Configuration → Mobile App UI** and adjust layouts (list card, detail sections, edit form).
4. Flutter app calls `mobile.ui.layout.get_mobile_layout('crm.lead', 'list'|'detail'|'form'|'create')` on lead screens.

### Remote server

Copy [odoo_addons/crm_mobile_ui](odoo_addons/crm_mobile_ui) into the server `addons_path`, install **CRM Mobile UI**, and set `ODOO_URL` / `ODOO_DB` via `--dart-define` or login fields.

See [odoo_addons/crm_mobile_ui/README.md](odoo_addons/crm_mobile_ui/README.md) for model and API details.

**Adding screens for other Odoo models:** step-by-step guide (Odoo layouts + Flutter feature wiring) — [docs/mobile-ui-screens.md](docs/mobile-ui-screens.md).

## Dynamic lead detail (fallback)

Without mobile layout, lead detail uses `crm.lead.get_views`, parses form XML, then `read`s displayable fields. Custom `x_*` fields not in the arch appear under **Other Information**.

Core layer: `lib/core/odoo/`. Mock: `assets/mock/crm_lead_form_schema.json`.

## Switching repositories to remote only

Already wired when `useRealApi = true`:

- [lib/features/auth/data/auth_repository.dart](lib/features/auth/data/auth_repository.dart) → `_signInRemote`
- [lib/features/lead/data/lead_repository.dart](lib/features/lead/data/lead_repository.dart) → `_fetchRemote`

## Theme

Odoo purple `#714B67` — [lib/app/theme/app_colors.dart](lib/app/theme/app_colors.dart)

## Routes

| Path | Screen |
|------|--------|
| `/splash` | Splash |
| `/login` | Login |
| `/dashboard` | Dashboard |
| `/leads` | Lead list (Odoo `crm.lead`) |
| `/leads/:id` | Lead detail (dynamic Odoo fields) |
| `/leads/:id/edit` | Edit lead |
| `/create-lead` | Create lead (layout `create` từ Odoo; fallback `form`) |
| `/orders` | Orders (mock) |
| `/profile` | Profile |
| `/settings` | Settings |
