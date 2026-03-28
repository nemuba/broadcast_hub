# AGENTS.md - BroadcastHub Development Guide

This document provides instructions for agentic coding tools (such as yourself) operating in the `broadcast_hub` repository. Adhere strictly to these guidelines to maintain consistency with the existing architecture.

---

## 1. Commands & Environment

BroadcastHub is a Ruby on Rails engine gem. Commands are executed from the repository root.

### Setup & Dependencies

- **Install gems**: `bundle install`
- **Database (Dummy App)**: `bundle exec rake db:migrate` (Runs in context of `spec/dummy`)
- **Generate documentation**: `bundle exec yard`

### Testing (RSpec)

- **Run all tests**: `bundle exec rspec`
- **Run single file**: `bundle exec rspec spec/models/concerns/broadcast_hub/broadcaster_spec.rb`
- **Run specific line**: `bundle exec rspec spec/models/concerns/broadcast_hub/broadcaster_spec.rb:45`
- **Run JavaScript controller specs**: `bundle exec rspec spec/javascripts/broadcast_hub/jquery_controller_spec.rb`
- **Run integration dispatch flow**: `bundle exec rspec spec/integration/broadcast_hub/dispatch_flow_spec.rb`
- **Fail fast**: `bundle exec rspec --fail-fast`

### Linting & Formatting (RuboCop)

- **Check all**: `bundle exec rubocop`
- **Auto-correct**: `bundle exec rubocop -a`
- **Layout only**: `bundle exec rubocop -x`

---

## 2. Ruby Code Style

BroadcastHub follows the **RuboCop Rails Omakase** house style.

### General Rules

- **Frozen String Literals**: EVERY Ruby file must start with `# frozen_string_literal: true`.
- **Namespacing**: All code must reside within the `BroadcastHub` module/namespace.
- **Documentation**: Use YARD-style tags (`@param`, `@return`, `@yield`) for public methods and service classes.
- **Naming**:
  - Modules/Classes: `PascalCase` (e.g., `PayloadBuilder`)
  - Methods/Variables: `snake_case` (e.g., `render_broadcast_content`)
- **Concerns**:
  - Located in `app/models/concerns/broadcast_hub/`.
  - Use `extend ActiveSupport::Concern`.
  - Wrap class-level macros in `class_methods` blocks.

### Error Handling

- Inherit from `StandardError` for domain-specific exceptions.
- Define internal error classes inside the relevant module/class (e.g., `BroadcastHub::PayloadBuilder::ValidationError`).

### Directory Structure

- `app/channels/`: Action Cable channel logic.
- `app/services/`: Stateless logic and business rules.
- `app/models/concerns/`: Reusable model behaviors.
- `lib/broadcast_hub/`: Engine core configuration and versioning.

---

## 3. JavaScript Code Style (Sprockets)

Frontend assets live in `app/javascripts/broadcast_hub/` and are intended for use with **Sprockets** and **jQuery**.

### Naming & Structure

- **Naming**:
  - Classes: `PascalCase` (e.g., `BroadcastHubSubscription`)
  - Methods/Variables: `camelCase` (e.g., `_handleReceived`)
- **Privacy**: Prefix internal/private methods with an underscore (`_`).
- **ES6 Compatibility**: Use ES6 classes, but avoid syntax that requires modern browser polyfills or breaks `uglifier` (Sprockets default). Prefer `export default class` for main modules.

### Integration

- Maintain compatibility with `jQuery`.
- Use the `BroadcastHubJQueryController` for DOM manipulations.

---

## 4. Architectural Patterns & Contracts

### Payload Contract (Broadcasting)

All payloads sent over `BroadcastHub::StreamChannel` must follow the contract enforced by `BroadcastHub::PayloadBuilder`:

```json
{
  "version": 1,
  "action": "append|prepend|update|remove|dispatch",
  "target": "#dom-target-selector",
  "content": "rendered-html-string or null",
  "id": "dom_element_id_123",
  "meta": {},
  "event_name": "custom:event:name",
  "event_data": {}
}
```

Notes:
- `event_name` and `event_data` are **dispatch-only** fields.
- For `append|prepend|update`, `content` is required.
- For `remove|dispatch`, `content` is `null`.

### Action Cable Streaming

- **Stream Key Resolution**: Always use the configured `stream_key_resolver` via `BroadcastHub.configuration`.
- **Authorization**: Subscription logic must check `authorize_scope` before establishing streams.

### Testing Strategy

- **Factories**: Define in `spec/factories/` using `FactoryBot`.
- **Dummy App**: Integration and controller tests target the app in `spec/dummy/`.
- **Context**: Use `BroadcastHub::StreamKeyContext` for consistent stream key resolution tests.
- **Backend contract tests**: Keep `PayloadBuilder` and `Broadcaster` specs updated when payload schema/actions change.
- **Frontend behavior tests**: Validate `BroadcastHubJQueryController` behavior in `spec/javascripts/` (using `ExecJS` + jQuery stub patterns present in the repository).

---

## 5. Verification Checklist

Before considering a task complete:

1. **Linting**: Run `bundle exec rubocop` and ensure zero offenses.
2. **Tests**: Run `bundle exec rspec` and ensure all tests pass.
3. **Ruby Idioms**: Verify the presence of `# frozen_string_literal: true`.
4. **Documentation**: Update README.md or YARD comments if public APIs changed.
5. **Contract**: If modifying broadcasting logic, ensure payload semantics stay aligned across `PayloadBuilder`, `Broadcaster`, `BroadcastHubJQueryController`, and README examples.
6. **Pre-existing issues**: If unrelated, pre-existing lint/test failures exist, do not hide them in feature changes; report them explicitly.
