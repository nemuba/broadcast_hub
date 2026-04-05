# Data Model - Add `replace` Broadcast Action

## Entity: Broadcast Action

- Description: Enumerated operation type consumed by payload producer and client runtime.
- Canonical values after change: `append`, `prepend`, `update`, `replace`, `remove`,
  `dispatch`.
- Validation rules:
  - MUST be one of canonical values.
  - Unknown value MUST raise `BroadcastHub::PayloadBuilder::ValidationError`.

## Entity: Broadcast Payload

- Description: Action Cable message envelope built by `BroadcastHub::PayloadBuilder`.
- Fields:
  - `version` (String/Number): payload schema version from configuration.
  - `action` (String): broadcast action enum.
  - `target` (String): CSS selector/DOM target.
  - `content` (String | nil): rendered HTML content.
  - `id` (String): unique identifier for fast-path targeting.
  - `meta` (Hash): metadata bag.
  - `event_name` (String, dispatch only).
  - `event_data` (Hash, dispatch only).
- Validation rules impacted by this feature:
  - `content` MUST be present for `append|prepend|update|replace`.
  - `content` MUST remain `nil` for `remove|dispatch`.
  - `event_name` required only for `dispatch`.
  - `event_data` must be a hash when present for `dispatch`.

## Entity: Target Element

- Description: DOM element(s) resolved from `payload.target` at client apply time.
- State transitions:
  - Existing + `replace` + valid content -> replaced by new markup.
  - Missing + `replace` -> safe no-op (no crash) with invalid/missing payload warning path
    unchanged.

## Entity: Validation Outcome

- Description: Result of payload validation and runtime application.
- States:
  - `accepted`: payload passes validation and action executes.
  - `rejected`: payload invalid at server contract level, raises validation error.
  - `ignored`: payload rejected at client guard path and not applied.

## Relationships

- `Broadcast Action` determines `Broadcast Payload` field constraints.
- `Broadcast Payload` references `Target Element` via `target` and optionally `id`.
- `Validation Outcome` is derived from server-side contract checks plus client-side payload
  guards.
