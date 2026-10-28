# SitoLogic design system

UI rules for SitoLogic. The interface is built from Bootstrap 5.3 primitives; the theme lives in `app/assets/stylesheets/theme.css`, which overrides Bootstrap CSS variables (Bootstrap is vendored precompiled, there is no Sass build). Follow this document for every new screen; when a rule has to change, change it here and in `theme.css` together.

## Interface language

The interface is Ukrainian only (`uk`): navigation, page titles, buttons, labels, hints, flash messages and validation errors. There is no language switch. Examples in this document use the Ukrainian wording that goes into the UI.

- Data stays bilingual: `*_en` / `*_ukr` columns are kept, and forms edit both.
- Views show `*_ukr` and fall back to `*_en` while the Ukrainian value is empty (the source database is English only).
- UI strings go through Rails I18n (`config/locales/uk.yml`), not hardcoded in views, so another language can be added later without touching templates.
- Numbers, dates and units follow Ukrainian conventions: decimal comma, `г`, `ккал`, `%`.

## Principles

- Calm, light interface: white surfaces on a light page, thin borders, almost no shadows.
- Colour carries meaning. Primary marks actions and the current location; status colours mean status; nutrient colours mean nutrients — nothing else.
- Never convey information by colour alone: status badges always have text, charts have labels or a legend.
- Use Bootstrap classes and utilities first; add a custom class to `theme.css` only when Bootstrap has nothing suitable.

## Colours

| Role | Value | Use |
|---|---|---|
| `primary` | `#0f766e` (hover `#0d635c`, active `#0b524c`) | main button, active nav item, links, focus |
| `primary-subtle` / `primary-emphasis` | `#e0f2f0` / `#0b4d47` | soft badges, selected rows, active item background |
| accent (`--sl-accent`, `.text-accent`) | `#f08c3a` | graphics only: logo, illustrations. Never text or buttons (contrast 2.5:1) |
| `secondary` | `#5f6b68` | secondary text, quiet buttons |
| `success` | `#2b7a3b` | "within norm", success messages |
| `warning` | `#e8a317`, dark text | "below norm", warnings |
| `danger` | `#c92a2a` | errors, deletion, "above norm" |
| `info` | `#1098ad`, dark text | rare informational notes |
| page background (`--sl-page-bg`) | `#f7f8f6` | `body` only |
| surfaces (`--bs-body-bg`) | `#ffffff` | cards, inputs, modals, navbar |
| text (`--bs-body-color`) | `#1f2a28` | body text |
| borders | `#e2e6e3`; inputs `#cdd4d0` | |

Primary is teal rather than green on purpose, so that actions are not confused with the "within norm" status.

### Nutrient colours

Fixed for charts, progress bars and markers. Text next to them keeps the normal colour.

| Nutrient | UI label | Colour | Classes |
|---|---|---|---|
| Protein | Білки | `#d6336c` | `.bg-protein`, `.text-protein` |
| Fat | Жири | `#e8a317` | `.bg-fat`, `.text-fat` |
| Carbohydrates | Вуглеводи | `#1c7ed6` | `.bg-carbs`, `.text-carbs` |
| Fibre | Клітковина | `#37b24d` | `.bg-fiber`, `.text-fiber` |
| Energy | Енергія, ккал | `primary` or neutral | |

Macronutrient split bar:

```erb
<div class="progress-stacked" style="height: .5rem">
  <div class="progress" role="progressbar" aria-label="Білки" style="width: 14%"><div class="progress-bar bg-protein"></div></div>
  <div class="progress" role="progressbar" aria-label="Жири" style="width: 16%"><div class="progress-bar bg-fat"></div></div>
  <div class="progress" role="progressbar" aria-label="Вуглеводи" style="width: 70%"><div class="progress-bar bg-carbs"></div></div>
</div>
```

### Norm status

Always a soft badge with text:

| Status | UI label | Classes |
|---|---|---|
| Below norm | Нижче норми | `badge bg-warning-subtle text-warning-emphasis` |
| Within norm | У нормі | `badge bg-success-subtle text-success-emphasis` |
| Above norm | Перевищення | `badge bg-danger-subtle text-danger-emphasis` |

## Logo

A balance ring: a primary ring with one accent segment (a balanced plate / nutrient split) and a primary leaf in the centre.

- Files: `public/icon.svg` (favicon, adapts to dark browser UI), `public/icon.png` (512 px, white background, for `apple-touch-icon` and PWA), `app/views/application/_logo.html.erb` (inline SVG for the UI, sized by `.app-logo`).
- Colours are fixed: primary `#0f766e`, accent `#f08c3a`; on dark backgrounds the primary becomes `#2db5a8`. Do not recolour, outline or add shadows.
- Minimum size 16 px. Keep clear space of at least a quarter of the logo width around it.
- The wordmark «SitoLogic» is set in the UI font, semibold, primary colour, to the right of the ring.

## Typography and shape

- Bootstrap system font stack (covers Cyrillic). Base size 1rem.
- Headings are semibold (600). No `display-*` classes on working screens.
- Numbers in tables and summaries: `.num` (tabular figures, right-aligned, no wrapping). Units go in the column header («Білки, г», «ккал»), not in each cell. Decimal separator is a comma.
- Reference codes (source, group type, group code): `.code`, or a soft badge `badge bg-primary-subtle text-primary-emphasis`.
- Radius: `.5rem` controls, `.75rem` cards and modals, `rounded-pill` badges.
- Shadows: none on cards (border only); dropdowns and modals keep Bootstrap's.
- Icons: Bootstrap Icons, always together with text. Icon-only buttons are allowed only in table rows and must have `title` and `aria-label`.

## Layout and navigation

- Top navbar: `navbar navbar-expand-lg app-navbar sticky-top`, white with a bottom border.
  - Left: brand — `render "logo"` + «SitoLogic» in primary.
  - Main sections, at most five: Меню · Раціони · Продукти · Довідники ▾ (Джерела, Групи, Нутрієнти).
  - The active link gets `.active` and `aria-current="page"`; it is shown in primary with a 2px underline.
  - Right: the user menu. No language switch while the interface is Ukrainian only.
- Sections with sub-pages (References) use a left column `col-lg-3` with `nav nav-pills flex-column` or `list-group`, not a second navbar.
- Breadcrumbs only deeper than two levels (Продукти → Група → Продукт).
- Page content: `container-xl py-4`; page header is an `h1.h3` with the main action aligned right.

## Buttons

| Kind | Class | When |
|---|---|---|
| Main | `btn btn-primary` | one per screen or block: «Зберегти», «Додати страву» |
| Secondary | `btn btn-outline-secondary` | «Скасувати», «Назад», «Експорт» |
| Destructive on a page | `btn btn-outline-danger` | «Видалити» — opens a confirmation |
| Destructive confirmation | `btn btn-danger` | only inside the confirmation modal |
| Text | `btn btn-link` | «Детальніше», «Показати всі» |
| Table row | add `btn-sm` | edit / delete a row |

- Labels are a verb + object («Додати продукт»), never «ОК» or «Надіслати».
- Order: secondary on the left, main on the right; groups aligned right (`d-flex justify-content-end gap-2`).
- Submit buttons use `data-turbo-submits-with` («Збереження…») instead of custom spinners.

## Forms

- Label above the field (`form-label`); placeholders never replace labels. Required fields: `<span class="required-mark">*</span>` after the label.
- Translatable fields (`*_en` / `*_ukr`) sit side by side in one row, the data language in a muted suffix of the label (the marker refers to the data, not to the interface):

  ```erb
  <div class="row g-3">
    <div class="col-md-6">
      <%= f.label :name_en, class: "form-label" do %>Назва <span class="text-body-secondary fw-normal">EN</span><% end %>
      <%= f.text_field :name_en, class: "form-control" %>
    </div>
    <div class="col-md-6">
      <%= f.label :name_ukr, class: "form-label" do %>Назва <span class="text-body-secondary fw-normal">UK</span><% end %>
      <%= f.text_field :name_ukr, class: "form-control" %>
    </div>
  </div>
  ```

- Numeric fields with units: `input-group` with `input-group-text` («г», «ккал», «%»).
- Validation: `is-invalid` on the field and `invalid-feedback` under it. An `alert alert-danger` summary at the top only when there are more than two errors.
- Width: forms are not full width — `col-lg-8` / `col-xl-6`. Long forms are split into cards with section headings.
- Actions at the bottom, separated by a top border (`border-top pt-3 mt-4`), per the button rules.

## Modals

- Used for confirmations and quick actions (picking a food for a dish, editing a portion). Long editing goes to a separate page.
- `modal-dialog-centered`; default size for confirmations, `modal-lg modal-dialog-scrollable` for pickers with search.
- White header with a question as the title («Видалити страву?»), the body says exactly what will happen, footer buttons follow the button rules.
- Content is loaded through a Turbo Frame and opened by a Stimulus controller; modals are not duplicated in every page's markup.

## Tables, cards, feedback

- Tables: `table table-hover align-middle` inside `table-responsive`. The header is tinted by the theme. Totals row is `fw-semibold`. Long lists: sticky header and pagination below; search and filters in a row above the table.
- Menus and diets are cards: day → meals → dishes. A meal card ends with the macronutrient split bar.
- Flash messages: success as a toast in the top-right corner, hidden after 4 s; errors as an inline `alert` that stays.
- Empty states: one short sentence and the main button («Меню ще немає» → «Створити меню»).

## Dark theme

Not supported yet. All colours are CSS variables, so it can be added later as a `[data-bs-theme=dark]` block in `theme.css`.
