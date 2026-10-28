# CLAUDE.md

This file provides Claude Code with context for working in this repository.

## Change workflow (mandatory)

Any change to the project (code, migrations, configuration, tests, fixtures, database data) must first be shown to the user and applied to the project only after their explicit approval.

- Before editing, describe what will change and why, and show the proposed code or diff for each file.
- Do not create, modify or delete project files, and do not run migrations, generators, import rake tasks or any other commands that change code or the database, until the user has agreed.
- Approval covers only the change that was shown; new or additional edits require approval again.
- Without approval, only non-modifying actions are allowed: reading files, searching, running tests and linters without autocorrect.

## About

SitoLogic is an early-stage Rails application for working with a food reference catalogue and nutritional data. Data is imported from an external SQLite database `vendor/db/dpx5db.sl3` (~140 MB, git-ignored, not in the repository) and stored in the application's own database with bilingual fields (English / Ukrainian).

## Stack

- Ruby 4.0.7 (`.ruby-version`), Rails 8.1
- SQLite (`storage/*.sqlite3`)
- Propshaft + importmap-rails (no Node/npm build), Turbo, Stimulus
- Bootstrap 5.3 vendored: `vendor/assets/stylesheets/bootstrap.min.css`, `vendor/javascript/bootstrap.js` and `@popperjs--core.js` (pinned in `config/importmap.rb`)
- Tests: Minitest + fixtures; system tests with Capybara/Selenium
- Style: `rubocop-rails-omakase`
- Disabled frameworks: Action Mailer, Action Mailbox, Action Cable (`config/application.rb`)

## Development environment

The main machine is Windows (`bin/dev` shebang is `ruby.exe`). Run commands via `bin/…`; in Git Bash use `ruby bin/rails …` if needed.

## Commands

```bash
bin/setup                      # install gems, prepare the database
bin/dev                        # start the server (rails server)
bin/rails db:migrate
bin/rails test                 # all tests
bin/rails test test/models/food_test.rb:12   # single test
bin/rails test:system
bin/rubocop                    # linter (-a to autocorrect)
bin/brakeman --no-pager
bin/bundler-audit
bin/importmap audit
bin/ci                         # full local CI (config/ci.rb)
bin/rails import:sources       # import sources from vendor/db/dpx5db.sl3
bin/rails import:groups        # import food groups from vendor/db/dpx5db.sl3
```

GitHub CI (`.github/workflows/ci.yml`): brakeman, bundler-audit, importmap audit, rubocop, tests and system tests. Before committing, run at least `bin/rubocop` and `bin/rails test`.

## Data model

Associations are based on string codes from the source database, not on `id`:

- `Source` (`code`, `group_type`, `name_en`, `name_ukr`) — data source; `group_type` is the food group type it uses (`GPM`, `GPS`, `GPT`, `GPU`, `GPE`, `G10`), `nil` for sources without groups. `has_many :foods` (by `source_code`), `has_many :groups` (by `group_type`)
- `Group` (`group_type`, `code`, `name_en`, `name_ukr`) — food group; belongs to a group type, not to a source (one type is shared by several sources). The code is unique only within a type (unique index on `group_type, code`). `has_many :sources` (by `group_type`), `has_many :foods` (composite key `[group_type, code]` ↔ `[group_type, group_code]`)
- `Food` (`code`, `source_code`, `group_type`, `group_code`, `name_*`, `description_*`, `comment_*` for `en`/`ukr`) — `belongs_to :source`; `belongs_to :group, optional: true` via composite key. `group_type` is denormalized from the source; `group_code` is `nil` for foods without a group

Conventions:
- Translatable fields are pairs of columns with `_en` / `_ukr` suffixes; follow the same pattern for new text fields.
- Declare new associations with explicit code-based `primary_key:` / `foreign_key:` (arrays for composite keys).
- Indexes: `sources.group_type`, unique `groups(group_type, code)`, `foods(group_type, group_code)`. Other codes have no indexes or uniqueness constraints yet.

## Import from dpx5db.sl3

Rake tasks in `lib/tasks/import.rake` (namespace `import`) open the source database read-only via the `sqlite3` gem, upsert with `find_or_initialize_by(code:)` inside a transaction, and strip whitespace from values. Implemented: `import:sources` (also sets `group_type`) and `import:groups`. There is no foods import task yet; when added, it must set `group_type` from the food's source and store an empty `GroupCode` as `nil`.

Main tables in the source database:
- `reference` (`Code`, `RefType`, `Name`) — lookup tables; `RefType = 'SRC'` — sources (27). `RefType = 'GLN'` maps a source code (`Code`) to its group type (`Name`); 8 sources have no `GLN` row and their foods have no group. Group types `G10`, `GPE`, `GPM`, `GPS`, `GPT`, `GPU` are themselves `RefType` values holding the groups (382 in total). Other types: `DSD`, `MPZ`, `PTN`, `WRC`.
- `food` (~33k) — `DataSource`, `FoodCode`, `GroupCode`, `Name`, `Description`, `Comment`, …
- `food_nutr` (~1.28M) — nutrient values (`FoodCode`, `NutrId`, `NutrValue`)
- `nutrient` (370) — nutrient definitions
- `food_prop`, `nutref`, `composite`, `ingredient`, etc.

The source database contains English names only; `*_ukr` fields are filled separately.

## UI and design

UI rules (palette, nutrient colours, navbar, buttons, forms, modals, tables) are in `docs/design-system.md`; the Bootstrap theme is `app/assets/stylesheets/theme.css` (CSS variable overrides, no Sass). Follow them for every new view and update both files together when a rule changes.

The interface language is Ukrainian only (no locale switch); UI strings go through I18n (`uk`). Data keeps the `_en` / `_ukr` column pairs.

## Misc

- The only routes are `root "dashboard#index"` (placeholder) and `/up`.
- Fixtures in `test/fixtures/*.yml` are generated placeholders (`MyString`); model tests are empty.
- Dependencies are updated by Dependabot (bundler and github-actions, weekly).
