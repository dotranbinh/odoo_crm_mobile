# Odoo CRM Mobile — Agent Context

Enterprise Flutter app for Odoo CRM with JSON-RPC integration and server-driven mobile UI layouts.

## Workspaces

| Path | Purpose |
|------|---------|
| `/Users/dotb/projects/crm_app` | Flutter mobile app (primary) |
| `/Users/dotb/projects/crm_odoo/crm_odoo_mobile` | Local Odoo Docker stack |
| `odoo_addons/crm_mobile_ui` | Odoo addon copy in Flutter repo |
| `crm_odoo/crm_odoo_mobile/custom-addons/crm_mobile_ui` | Live addon mounted in Docker |

## Tech stack

- Flutter 3.10+ · Dart SDK ^3.10
- flutter_riverpod · go_router · Dio · freezed · json_serializable · intl
- Odoo 17 JSON-RPC via `/web/session/authenticate` and `/web/dataset/call_kw`

## Dev commands

```bash
# Flutter setup
flutter pub get
dart run build_runner build
flutter gen-l10n

# Run (override Odoo endpoint)
flutter run --dart-define=ODOO_URL=http://localhost:8069 --dart-define=ODOO_DB=dev1

# Web with CORS workaround
./run-local.sh

# Analyze
flutter analyze
flutter test
```

**Android emulator:** rewrite `localhost` to `10.0.2.2` automatically.
**Physical device:** use LAN IP (e.g. `http://172.16.252.252:8069`).

## Odoo operations

```bash
cd /Users/dotb/projects/crm_odoo/crm_odoo_mobile
docker compose up -d
docker compose exec odoo odoo -u crm_mobile_ui -d dev1 --stop-after-init
docker compose restart odoo
```

Default database: `dev1`. Addon menu: **CRM → Configuration → Mobile App UI**.

## App config flags

In `lib/app/constants/app_config.dart`:

| Flag | Default | Meaning |
|------|---------|---------|
| `useRealApi` | `true` | Live Odoo auth + leads |
| `useMobileUiConfig` | `true` | Load layouts from `crm_mobile_ui` addon |
| `mobileUiFallbackToFormXml` | `true` | Fall back to `get_views` when layout version is 0 |

## Routes

| Path | Screen |
|------|--------|
| `/splash` | Splash |
| `/login` | Login |
| `/dashboard` | Dashboard |
| `/leads` | Lead list |
| `/leads/:id` | Lead detail |
| `/leads/:id/edit` | Edit lead |
| `/create-lead` | Create lead |
| `/orders` | Orders (mock) |
| `/profile` | Profile |
| `/settings` | Settings |

Screen docs: `docs/screens/` (Vietnamese). Architecture guide: `docs/mobile-ui-screens.md`.

## UI conventions

Follow `design.md`:

- Primary: `#534AB7` · tint bg: `#EEEDFE` · tint text: `#3C3489`
- Weights: regular (400) and medium (500) only — no bold/700
- Card: 16px radius, 0.5px border `#E5E1EA`, no drop shadows
- Screen padding: 18px horizontal
- Icons: Tabler outline style

## Project structure

```
lib/
├── app/           # theme, router, AppConfig
├── core/          # Odoo JSON-RPC, mobile_ui mapper, widgets
├── features/      # auth, dashboard, lead, order, profile, settings
└── l10n/
```

## JSON-RPC endpoints

| Endpoint | Purpose |
|----------|---------|
| `POST /web/session/authenticate` | Login |
| `POST /web/dataset/call_kw` | CRUD on `crm.lead`, `get_views` |
| `mobile.ui.layout.get_mobile_layout` | Server-driven list/detail/form/create layouts |
| `POST /web/session/destroy` | Logout |

## Conventions

- Code and comments: English
- Screen documentation: Vietnamese (`docs/screens/`)
- Prefer feature-first layout under `lib/features/<name>/`
- Match existing Riverpod and go_router patterns before adding new abstractions
- Run `build_runner` after changing `@freezed` or `@JsonSerializable` models
