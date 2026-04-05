# Implementation Plan: Add `replace` Broadcast Action

**Branch**: `001-add-broadcast-action` | **Date**: 2026-04-05 | **Spec**: `/home/siedos/projects/local/broadcast_hub/specs/001-add-broadcast-action/spec.md`
**Input**: Feature specification from `/home/siedos/projects/local/broadcast_hub/specs/001-add-broadcast-action/spec.md`

**Note**: This template is filled in by the `/speckit.plan` command. See `.specify/templates/plan-template.md` for the execution workflow.

## Summary

Introduce a new `replace` broadcast action to support full element replacement in one
operation, while preserving behavior of existing actions (`append`, `prepend`, `update`,
`remove`, `dispatch`).

Implementation follows the existing contract-first architecture: extend payload validation
and controller/model helper action sets in Ruby, add deterministic client-side behavior in
the jQuery controller, and update docs + tests in the same change.

## Technical Context

<!--
  ACTION REQUIRED: Replace the content in this section with the technical details
  for the project. The structure here is presented in advisory capacity to guide
  the iteration process.
-->

**Language/Version**: Ruby (Rails engine for Rails >= 5.2 and < 7.0), ES6 JavaScript (Sprockets/Uglifier-compatible)  
**Primary Dependencies**: Rails/Action Cable, jquery-rails, RSpec, RuboCop Rails Omakase  
**Storage**: N/A (contract/runtime behavior only; no schema persistence changes)  
**Testing**: RSpec (service/model/controller/javascript/integration specs)  
**Target Platform**: Rails host applications using Action Cable + browser clients with jQuery runtime
**Project Type**: Reusable Rails engine gem  
**Performance Goals**: Preserve current broadcast latency characteristics; no additional network round trips; deterministic single-pass DOM operation for `replace`  
**Constraints**: Backward compatibility for all existing actions; contract parity between Ruby and JavaScript; authorization/scope behavior unchanged  
**Scale/Scope**: Single new action (`replace`) across payload builder, broadcaster/controller helpers, JS apply logic, tests, and documentation

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

- [ ] Contract integrity: payload/action changes are identified, and contract updates are
      planned across Ruby + JavaScript + docs.
- [ ] Authorization and stream scope: subscription and stream key impacts are listed,
      including how `authorize_scope` and resolver behavior remain correct.
- [ ] Test-first safety: failing tests are planned before implementation for each behavior
      change; integration coverage is planned where channel/controller/DOM behavior changes.
- [ ] Engine boundaries: business logic placement follows service/domain boundaries and avoids
      cross-engine coupling.
- [ ] Documentation and verification: README/YARD/RDoc update needs are listed; verification
      commands (`bundle exec rubocop`, focused specs, and full `bundle exec rspec` when
      feasible) are included in plan execution.

Initial gate assessment (pre-Phase 0):

- [x] Contract integrity: `replace` will be added to action enum and content rules in
      payload contract, Ruby helpers, JavaScript runtime, and README examples.
- [x] Authorization and stream scope: no channel/stream scope logic change; existing
      `authorize_scope` and stream key resolver flows remain the same.
- [x] Test-first safety: plan includes fail-first updates in
      `spec/services/broadcast_hub/payload_builder_spec.rb`,
      `spec/controllers/broadcast_hub/controller_helpers_spec.rb`,
      `spec/models/concerns/broadcast_hub/broadcaster_spec.rb`,
      `spec/javascripts/broadcast_hub/jquery_controller_spec.rb`, and integration coverage
      where action flow crosses boundaries.
- [x] Engine boundaries: changes remain in payload/service/helper/runtime layers; no new
      domain logic in controllers/models beyond existing concern APIs.
- [x] Documentation and verification: README + YARD comments updated in touched public APIs;
      verification commands include `bundle exec rubocop`, focused specs, and full
      `bundle exec rspec` when feasible.

## Project Structure

### Documentation (this feature)

```text
specs/001-add-broadcast-action/
├── plan.md              # This file (/speckit.plan command output)
├── research.md          # Phase 0 output (/speckit.plan command)
├── data-model.md        # Phase 1 output (/speckit.plan command)
├── quickstart.md        # Phase 1 output (/speckit.plan command)
├── contracts/           # Phase 1 output (/speckit.plan command)
└── tasks.md             # Phase 2 output (/speckit.tasks command - NOT created by /speckit.plan)
```

### Source Code (repository root)
<!--
  ACTION REQUIRED: Replace the placeholder tree below with the concrete layout
  for this feature. Delete unused options and expand the chosen structure with
  real paths (e.g., apps/admin, packages/something). The delivered plan must
  not include Option labels.
-->

```text
app/
├── controllers/concerns/broadcast_hub/controller_helpers.rb
├── javascripts/broadcast_hub/jquery_controller.js
├── models/concerns/broadcast_hub/broadcaster.rb
└── services/broadcast_hub/payload_builder.rb

spec/
├── controllers/broadcast_hub/controller_helpers_spec.rb
├── javascripts/broadcast_hub/jquery_controller_spec.rb
├── models/concerns/broadcast_hub/broadcaster_spec.rb
├── services/broadcast_hub/payload_builder_spec.rb
└── integration/broadcast_hub/dispatch_flow_spec.rb

README.md
```

**Structure Decision**: Keep existing Rails engine structure and extend only files that
already own action contract, broadcast orchestration, and DOM application behavior. No new
top-level modules or subsystems are required for this action addition.

## Post-Design Constitution Check

- [x] Contract integrity: Research + contract doc define `replace` semantics and mandatory
      updates across builder, helpers, runtime, tests, and docs.
- [x] Authorization and stream scope: Design keeps existing `authorize_scope` and stream key
      resolver paths unchanged.
- [x] Test-first safety: Quickstart mandates fail-first spec updates before implementation.
- [x] Engine boundaries: No new cross-layer leakage; action handling remains in service and
      runtime adapters.
- [x] Documentation and verification: README/YARD updates and verification commands are
      explicitly listed in quickstart.

## Complexity Tracking

> **Fill ONLY if Constitution Check has violations that must be justified**

| Violation | Why Needed | Simpler Alternative Rejected Because |
|-----------|------------|-------------------------------------|
| [e.g., 4th project] | [current need] | [why 3 projects insufficient] |
| [e.g., Repository pattern] | [specific problem] | [why direct DB access insufficient] |
