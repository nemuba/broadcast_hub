# Quickstart - Implement and Validate `replace` Action

## 1) Implement contract updates (Ruby)

Update action lists and validation categories in:

- `app/services/broadcast_hub/payload_builder.rb`
- `app/controllers/concerns/broadcast_hub/controller_helpers.rb`
- `app/models/concerns/broadcast_hub/broadcaster.rb`

Expected outcome:

- `replace` is recognized as valid action.
- `replace` requires rendered `content`.

## 2) Implement client runtime behavior (JavaScript)

Update:

- `app/javascripts/broadcast_hub/jquery_controller.js`

Expected outcome:

- `replace` action replaces target element(s) with payload `content`.
- Invalid payload protections remain active.

## 3) Add/adjust tests (fail-first then pass)

Primary files:

- `spec/services/broadcast_hub/payload_builder_spec.rb`
- `spec/controllers/broadcast_hub/controller_helpers_spec.rb`
- `spec/models/concerns/broadcast_hub/broadcaster_spec.rb`
- `spec/javascripts/broadcast_hub/jquery_controller_spec.rb`
- `spec/integration/broadcast_hub/dispatch_flow_spec.rb` (or nearest integration flow file)

Suggested focused runs during development:

```bash
bundle exec rspec spec/services/broadcast_hub/payload_builder_spec.rb
bundle exec rspec spec/controllers/broadcast_hub/controller_helpers_spec.rb
bundle exec rspec spec/models/concerns/broadcast_hub/broadcaster_spec.rb
bundle exec rspec spec/javascripts/broadcast_hub/jquery_controller_spec.rb
```

## 4) Update docs

Update public usage and payload contract docs in:

- `README.md`
- YARD comments in touched public Ruby APIs (where action lists are documented)

Expected outcome:

- README includes `replace` in action list and examples.
- Contract rules clearly separate content-required vs content-forbidden actions.

## 5) Run verification gates

From repository root:

```bash
bundle exec rubocop
bundle exec rspec
```

If full suite is not feasible in one pass, run focused suites first and report any unrelated
pre-existing failures explicitly.

## 6) Manual-flow elimination checklist

Use this checklist to validate SC-004 (replace removes at least one manual UI flow):

- [ ] Record previous flow: target block update required manual DOM orchestration.
- [ ] Run same flow using single `replace` broadcast payload.
- [ ] Confirm no extra manual DOM fallback step is required.
- [ ] Capture result in PR notes with before/after flow summary.

## 7) Integrator <=15-minute validation checklist

Use this timed checklist to validate SC-003:

- [ ] Start timer and apply README setup instructions for `replace`.
- [ ] Produce one working `replace` payload example in a host app flow.
- [ ] Confirm client runtime applies replacement as expected.
- [ ] Finish in 15 minutes or less and record elapsed time in PR notes.
