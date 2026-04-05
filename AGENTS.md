# AGENTS.md - BroadcastHub Development Guide

This guide is for coding agents working in `broadcast_hub`.
BroadcastHub is a Rails engine gem for Action Cable payload broadcasting.

## 0. Memory-First Planning Gate

Before any planning activity (implementation/debug/refactor plans), run this sequence:

1. Read the current `[MEMORY]` block fully.
2. Run `memory.search` with request-specific terms (feature names, paths, issue IDs, domain words).
3. Output a short `Relevant Memory` summary before the plan.
4. If nothing relevant is found, write exactly: `No relevant memory found`.
Do not start planning before this gate is complete.

## 1. Build, Lint, and Test Commands

Run commands from repository root.

### Setup

- Install dependencies: `bundle install`
- Migrate dummy app DB: `bundle exec rake db:migrate`
- Generate YARD docs: `bundle exec yard`
- Generate RDoc docs: `bundle exec rake rdoc`

### Tests (RSpec)

- Run all tests: `bundle exec rspec`
- Run a single file: `bundle exec rspec spec/models/concerns/broadcast_hub/broadcaster_spec.rb`
- Run a single test by line: `bundle exec rspec spec/models/concerns/broadcast_hub/broadcaster_spec.rb:45`
- Run by example name: `bundle exec rspec spec/services/broadcast_hub/payload_builder_spec.rb -e "dispatch"`
- Run controller helper tests: `bundle exec rspec spec/controllers/broadcast_hub/controller_helpers_spec.rb`
- Run JS controller tests: `bundle exec rspec spec/javascripts/broadcast_hub/jquery_controller_spec.rb`
- Run integration dispatch flow: `bundle exec rspec spec/integration/broadcast_hub/dispatch_flow_spec.rb`
- Fail fast: `bundle exec rspec --fail-fast`

### Linting / Formatting

- Lint all Ruby: `bundle exec rubocop`
- Auto-correct safe issues: `bundle exec rubocop -a`
- Run layout cops only: `bundle exec rubocop -x`

## 2. Repository Layout

- `app/channels/broadcast_hub/`: Action Cable channel logic.
- `app/controllers/concerns/broadcast_hub/`: controller concerns.
- `app/helpers/broadcast_hub/`: helper modules (including `dom_id` helper).
- `app/models/concerns/broadcast_hub/`: model concerns.
- `app/services/broadcast_hub/`: service objects and payload/stream utilities.
- `app/javascripts/broadcast_hub/`: Sprockets + jQuery runtime files.
- `lib/broadcast_hub/`: engine boot/config/version and entrypoint requires.
- `spec/`: unit/controller/channel/integration/javascript specs.
- `spec/dummy/`: dummy Rails app for integration/controller behavior.

## 3. Ruby Code Style

Style source: `.rubocop.yml` with `rubocop-rails-omakase`.

### File and Namespace Rules

- Every Ruby file must begin with `# frozen_string_literal: true`.
- Keep code under `BroadcastHub` namespace.
- Keep path-to-constant alignment (example: `app/services/broadcast_hub/payload_builder.rb` -> `BroadcastHub::PayloadBuilder`).
- Keep classes/modules focused on one responsibility.

### Imports and Formatting

- Put `require` lines at top of file, after frozen string comment.
- Use `require "..."` with double quotes for consistency.
- Use 2-space indentation.
- Prefer guard clauses for validation and early returns.
- Use frozen constants (`.freeze`) for action/key lists and stable schemas.

### Types, Naming, and Docs

- Ruby is dynamic; express expected input/output via YARD on public APIs.
- Use YARD tags like `@param`, `@return`, `@raise` where contract matters.
- Classes/modules: `PascalCase`.
- Methods/locals/keywords: `snake_case`.
- Predicates end in `?`; strict/raising methods may use `!`.

### Error Handling

- Use domain-specific errors within owning class/module (`< StandardError`).
- Use `ArgumentError` for invalid API inputs.
- Rescue narrowly; avoid broad blanket rescue unless intentionally normalizing framework edge-cases.
- If using `rescue StandardError`, re-raise unexpected errors.

## 4. JavaScript Code Style (Sprockets + jQuery)

Code lives in `app/javascripts/broadcast_hub/`.

### Syntax and Compatibility

- Use ES6 classes/modules compatible with Rails 5/6 Sprockets + Uglifier pipelines.
- Prefer `const`/`let`, not `var`.
- Keep semicolon usage consistent.

### Imports/Exports and Naming

- Use relative imports (`./subscription`, `./jquery_controller`).
- Default-export one primary class per module.
- Keep global attachment logic in `index.js`.
- Classes: `PascalCase`; methods/variables: `camelCase`.
- Internal/private methods should be prefixed with `_`.

### Validation and Errors

- Validate payload/resource input before side effects.
- Throw `Error` for direct API misuse (e.g., missing `resource`).
- In DOM controller, prefer safe no-op + dev warning when payload is invalid.

## 5. Core Architecture Contracts

### Payload Contract

`BroadcastHub::PayloadBuilder` is the source of truth for broadcast payload shape.

- Base fields: `version`, `action`, `target`, `content`, `id`, `meta`.
- Dispatch-only fields: `event_name`, `event_data`.
- `action` must be one of `append|prepend|update|remove|dispatch`.
- `content` required for `append|prepend|update`.
- `content` must be `nil` for `remove|dispatch`.
- `event_name` required for `dispatch`.
- `event_data` must be a hash when present.

### Streaming and Authorization

- Resolve stream keys through configured resolver (`BroadcastHub.configuration.stream_key_resolver`).
- Enforce `authorize_scope` before channel subscription.

### Controller Helper Contract

- Use `render_broadcast` for controller-triggered broadcast actions.
- Required args: `action`, `target`, `resource`.
- For `append|prepend|update`, `partial` is required.
- For `remove|dispatch`, `content` stays `nil`.
- Keep controller response formats explicit (`respond_to` only for supported formats).

### Dom ID Helper Contract

- Public API: `dom_id(record, positional_prefix = nil, prefix: nil, suffix: nil)`.
- Preserve Rails positional prefix behavior (`dom_id(todo, :edit)` -> `edit_todo_1`).
- Keyword wrappers compose around base id (`prefix` before, `suffix` after).
- If positional prefix and keyword `prefix` are both given, raise `ArgumentError`.

## 6. Testing and Change Expectations

- Keep factories under `spec/factories/`.
- Update affected tests in same change as behavior changes.
- Keep payload/broadcaster/JS controller contract tests aligned.
- Prefer targeted test runs first; run full suite before final completion when feasible.
- Update README/YARD when public API or behavior changes.

## 7. Cursor/Copilot Rules Status

Repository scan result:

- `.cursor/rules/`: not present
- `.cursorrules`: not present
- `.github/copilot-instructions.md`: not present
If these files are added later, treat them as mandatory additional instructions.

## 8. Completion Checklist

Before marking work complete:

1. Run `bundle exec rubocop` (or report pre-existing unrelated offenses).
2. Run relevant focused specs, then `bundle exec rspec` when feasible.
3. Verify `# frozen_string_literal: true` in changed Ruby files.
4. Verify contracts remain aligned across payload builder, broadcaster, controller helper, JS controller, and README.
5. Report unrelated pre-existing test/lint failures explicitly.

## Active Technologies

- Ruby (Rails engine for Rails >= 5.2 and < 7.0), ES6 JavaScript (Sprockets/Uglifier-compatible) + Rails/Action Cable, jquery-rails, RSpec, RuboCop Rails Omakase (001-add-broadcast-action)
- N/A (contract/runtime behavior only; no schema persistence changes) (001-add-broadcast-action)

## Recent Changes

- 001-add-broadcast-action: Added Ruby (Rails engine for Rails >= 5.2 and < 7.0), ES6 JavaScript (Sprockets/Uglifier-compatible) + Rails/Action Cable, jquery-rails, RSpec, RuboCop Rails Omakase
