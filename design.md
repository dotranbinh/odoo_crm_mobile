# Odoo CRM Mobile — Design Spec (for implementation handoff)

This document describes the redesigned CRM mobile app: a modern, native-feeling iOS-leaning style with a refined purple brand color. Use it together with `mockup.html` (visual reference) and screenshots of each screen when prompting Cursor.

## 1. Brand color

| Token | Hex | Usage |
|---|---|---|
| Primary | `#534AB7` | Primary buttons, active states, icons on accent fill |
| Primary tint (light) | `#EEEDFE` | Chip/badge backgrounds, icon backgrounds, selected pills |
| Primary tint (text) | `#3C3489` | Text/icon color when placed on the light tint |

## 2. Status colors (semantic)

| Status | Background | Text |
|---|---|---|
| New | `#EEEDFE` | `#3C3489` |
| Qualified | `#FAEEDA` | `#633806` |
| Won | `#E1F5EE` | `#085041` |
| Lost | `#FAECE7` | `#712B13` |

Pipeline composition bar uses brighter mid-tones for visibility on a thin bar: New `#7F77DD`, Qualified `#EF9F27`, Won `#1D9E75`.

## 3. Neutrals

| Token | Hex | Usage |
|---|---|---|
| Text primary | `#1C1C1E` | Headings, body text |
| Text secondary / muted | `#8E8E93` | Labels, captions, timestamps |
| Text tertiary | `#5A5A5E` | Secondary row text |
| Border | `#E5E1EA` | Card borders, dividers (0.5px) |
| Surface tint | `#F7F7F8` | Search bars, stat strips, secondary buttons |
| Card background | `#FFFFFF` | All cards |
| Screen background | `#FFFFFF` | Default screen bg (no gray canvas) |

## 4. Typography

- Font: system font stack (SF Pro on iOS, Roboto on Android — let the native platform default apply).
- Weights: regular (400) and medium (500) only. Avoid bold/700 anywhere — keep the UI calm.
- Sizes used: 26px (hero numbers), 20–22px (page titles), 18px (name on detail), 15–16px (body / buttons), 13–14px (secondary body), 11–12px (captions/labels), all sentence case (no ALL CAPS).

## 5. Spacing & shape

- Screen horizontal padding: 18px.
- Card radius: 16px. Pill/badge radius: 999px (fully round). Avatar radius: 50%.
- Card border: 0.5px solid `#E5E1EA`, no drop shadows — depth comes from flat color tints and thin borders, not elevation shadows.
- Bottom nav: 5-column grid (Home, Leads, [gap], Orders, Profile), with a circular "Add" button absolutely positioned in the center, raised above the divider line, white 4px ring instead of a shadow for depth.

## 6. Icons

Tabler Icons (outline style), 16–22px depending on context. Key icons used: `link`, `database`, `user`, `lock`, `eye`/`eye-off`, `server`, `chevron-down`, `fingerprint`, `bell`, `user-plus`, `shopping-bag`, `search`, `phone`, `mail`, `message-circle`, `copy`, `arrow-left`, `edit`, `notes`, `layout-grid`, `users`, `plus`.

## 7. Components

- **Input row**: single white bordered rounded rect (12px radius, 0.5px `#E5E1EA` border, ~14px/11px padding). Leading icon (16px, muted) + inline text field (15px primary) + optional trailing icon (e.g. password show/hide). Label above in muted 12px text. No nested/inner box.
- **Card**: white, 0.5px border, 16px radius, 14–16px padding. Internal rows separated by 0.5px dividers (no divider after the last row).
- **Status badge/chip**: small pill, 11px medium text, colored per status table above.
- **Avatar**: circle, initials, background = status tint, text = status text color.
- **Underline tabs**: text-only tabs in a row; active tab gets a 2px accent underline and accent-dark text color; inactive tabs are muted gray, no background.
- **Segmented control** (top-level screen switcher in the mockup only — not part of the real app): pill-shaped container with sliding active background.

## 8. Screens

### Sign in
Brand mark (rounded-square icon tile) + "Welcome back" headline + one-line subtext. Two visible fields: email/username, password (with working show/hide toggle). Advanced "Server settings" (Odoo URL + Database) collapsed by default behind an expandable row — most end users never touch this after first setup. Primary "Sign in" button, then a secondary "Use Face ID" biometric option below a divider. No "remember me" toggle — sessions persist by default, removing unnecessary friction.

**Implementation:** [`lib/features/auth/presentation/login_screen.dart`](lib/features/auth/presentation/login_screen.dart)  
**Visual mockup:** [`mockup.html`](mockup.html) (`#signin`)

### Dashboard
Header: avatar + time-aware greeting ("Good afternoon, Administrator") + notification bell with unread dot. Hero card: "Pipeline value" with a large number and a horizontal stacked composition bar (New/Qualified/Won proportions) plus a color-coded legend — replaces a flat percentage-trend stat tile with something that actually shows pipeline shape. Below it: a single card split into 3 columns (Total leads / New leads / Orders) with thin vertical dividers instead of 4 separate boxed tiles. Quick actions: 3 circular icon buttons (New lead, New order, Search). Recent activity: a vertical timeline (dot + connecting line) with 2 entries.

### Leads
Header with title + total count. Search bar. Status filter as underline tabs (All/New/Qualified/Won/Lost) instead of colored chip pills, for a cleaner scan line. Lead cards: avatar with initials (color = status tint), name + company, status badge top-right, phone number, and a **relative timestamp** ("2 days ago") instead of an absolute date — intentional for a global audience to avoid locale-specific date formatting.

### Lead detail
Minimal header (back, breadcrumb label, edit). Large centered avatar, name, company, status badge. Three circular contact actions (Call, Message, Email) — Contacts-app style instead of three bordered buttons. Sub-navigation via underline tabs: Info (contact/address/opportunity grouped cards), Notes (empty state), Activity (timeline, same pattern as dashboard).

## 9. Interaction notes (for native implementation)

- Password field: tap the eye icon to toggle masked/plain text.
- "Server settings" row: tap to expand/collapse the Odoo URL + Database fields.
- Lead detail sub-tabs (Info/Notes/Activity): tap to switch content, underline indicator follows.
- Bottom nav "Add" button: always centered and raised, regardless of which tab is active — it's a global action, not a page state.