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
```

GitHub CI (`.github/workflows/ci.yml`): brakeman, bundler-audit, importmap audit, rubocop, tests and system tests. Before committing, run at least `bin/rubocop` and `bin/rails test`.

## Data model

Associations are based on string codes from the source database, not on `id`:

- `Source` (`code`, `name_en`, `name_ukr`) — data source; `has_many :foods, primary_key: :code, foreign_key: :source_code`
- `Group` (`source_code`, `code`, `name_en`, `name_ukr`) — food group; the group code is unique within a source. No associations declared yet.
- `Food` (`code`, `source_code`, `group_code`, `name_*`, `description_*`, `comment_*` for `en`/`ukr`) — `belongs_to :source, foreign_key: :source_code, primary_key: :code`

Conventions:
- Translatable fields are pairs of columns with `_en` / `_ukr` suffixes; follow the same pattern for new text fields.
- Declare new associations with explicit code-based `primary_key:` / `foreign_key:`.
- There are no indexes or uniqueness constraints on codes yet.

## Import from dpx5db.sl3

Rake tasks in `lib/tasks/import.rake` (namespace `import`) open the source database read-only via the `sqlite3` gem, upsert with `find_or_initialize_by(code:)` inside a transaction, and strip whitespace from values. Only `import:sources` is implemented so far.

Main tables in the source database:
- `reference` (`Code`, `RefType`, `Name`) — lookup tables; `RefType = 'SRC'` — sources (27). Other types: `DSD`, `G10`, `GLN`, `GP*`, `MPZ`, `PTN`, `WRC`.
- `food` (~33k) — `DataSource`, `FoodCode`, `GroupCode`, `Name`, `Description`, `Comment`, …
- `food_nutr` (~1.28M) — nutrient values (`FoodCode`, `NutrId`, `NutrValue`)
- `nutrient` (370) — nutrient definitions
- `food_prop`, `nutref`, `composite`, `ingredient`, etc.

The source database contains English names only; `*_ukr` fields are filled separately.

## Misc

- The only routes are `root "dashboard#index"` (placeholder) and `/up`.
- Fixtures in `test/fixtures/*.yml` are generated placeholders (`MyString`); model tests are empty.
- Dependencies are updated by Dependabot (bundler and github-actions, weekly).
