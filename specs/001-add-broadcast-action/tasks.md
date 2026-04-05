# Tasks: Add `replace` Broadcast Action

**Input**: Design documents from `/specs/001-add-broadcast-action/`
**Prerequisites**: plan.md (required), spec.md (required for user stories), research.md, data-model.md, contracts/

**Tests**: Test tasks are included for every user story that changes behavior.

**Organization**: Tasks are grouped by user story to enable independent implementation and testing of each story.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies)
- **[Story]**: Which user story this task belongs to (e.g., US1, US2, US3)
- Include exact file paths in descriptions

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: Prepare baseline and verification flow for safe contract evolution.

- [x] T001 Confirm baseline action contract and integration scope in `specs/001-add-broadcast-action/contracts/payload-replace-action.md`
- [x] T002 [P] Capture current behavior reference in `specs/001-add-broadcast-action/research.md` for `append|prepend|update|remove|dispatch`
- [x] T003 [P] Prepare verification command checklist in `specs/001-add-broadcast-action/quickstart.md` with focused + full-suite runs

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Establish shared contract primitives required by all stories.

**CRITICAL**: No user story work can begin until this phase is complete.

- [x] T004 Add `replace` to action enum in `app/services/broadcast_hub/payload_builder.rb`
- [x] T005 Update content-required action set to include `replace` in `app/services/broadcast_hub/payload_builder.rb`
- [x] T006 [P] Add/adjust YARD API comments for new action in `app/services/broadcast_hub/payload_builder.rb`
- [x] T007 [P] Add `replace` to controller helper allowed actions in `app/controllers/concerns/broadcast_hub/controller_helpers.rb`
- [x] T008 [P] Add `replace` to broadcaster concern allowed actions in `app/models/concerns/broadcast_hub/broadcaster.rb`

**Checkpoint**: Foundation ready - user story implementation can begin.

---

## Phase 3: User Story 1 - Identificar acao recomendada (Priority: P1) 🎯 MVP

**Goal**: Formalize and validate `replace` as the recommended new action with explicit contract semantics.

**Independent Test**: Recommendation and contract semantics are validated by payload-builder contract specs and documented behavior.

### Tests for User Story 1 (REQUIRED)

- [x] T009 [P] [US1] Add failing contract examples for `replace` action acceptance/rejection in `spec/services/broadcast_hub/payload_builder_spec.rb`
- [x] T010 [P] [US1] Add failing helper action-allowlist specs for `replace` in `spec/controllers/broadcast_hub/controller_helpers_spec.rb`

### Implementation for User Story 1

- [x] T011 [US1] Implement payload validation behavior for `replace` in `app/services/broadcast_hub/payload_builder.rb`
- [x] T012 [US1] Implement controller helper acceptance for `replace` in `app/controllers/concerns/broadcast_hub/controller_helpers.rb`
- [x] T013 [US1] Update recommendation rationale and action boundaries in `specs/001-add-broadcast-action/research.md`
- [x] T014 [US1] Run focused US1 specs in `spec/services/broadcast_hub/payload_builder_spec.rb` and `spec/controllers/broadcast_hub/controller_helpers_spec.rb`

**Checkpoint**: `replace` is a documented and validated first-class action at contract/helper level.

---

## Phase 4: User Story 2 - Usar nova acao de substituicao (Priority: P2)

**Goal**: Enable deterministic client-visible full replacement behavior via the new action.

**Independent Test**: A payload with `action: replace` replaces target element content in runtime behavior tests.

### Tests for User Story 2 (REQUIRED)

- [x] T015 [P] [US2] Add failing `replace` runtime behavior specs in `spec/javascripts/broadcast_hub/jquery_controller_spec.rb`
- [x] T016 [P] [US2] Add failing broadcaster flow specs for `replace` in `spec/models/concerns/broadcast_hub/broadcaster_spec.rb`

### Implementation for User Story 2

- [x] T017 [US2] Implement `replace` branch in client runtime apply flow in `app/javascripts/broadcast_hub/jquery_controller.js`
- [x] T018 [US2] Implement broadcaster concern support for `replace` action flow in `app/models/concerns/broadcast_hub/broadcaster.rb`
- [x] T019 [US2] Update payload contract example and semantics for `replace` in `specs/001-add-broadcast-action/contracts/payload-replace-action.md`
- [x] T020 [US2] Run focused US2 specs in `spec/javascripts/broadcast_hub/jquery_controller_spec.rb` and `spec/models/concerns/broadcast_hub/broadcaster_spec.rb`

**Checkpoint**: `replace` works end-to-end for producer/runtime behavior without altering existing actions.

---

## Phase 5: User Story 3 - Validacao e seguranca de contrato (Priority: P3)

**Goal**: Guarantee invalid payload safety and backward compatibility with existing action set.

**Independent Test**: Invalid `replace` payloads are rejected/ignored safely, and regression checks confirm unchanged behavior for existing actions.

### Tests for User Story 3 (REQUIRED)

- [x] T021 [P] [US3] Add failing invalid-payload safety cases for `replace` in `spec/services/broadcast_hub/payload_builder_spec.rb`
- [x] T022 [P] [US3] Add failing integration regression coverage for action compatibility in `spec/integration/broadcast_hub/dispatch_flow_spec.rb`

### Implementation for User Story 3

- [x] T023 [US3] Implement/adjust defensive invalid payload handling for `replace` in `app/javascripts/broadcast_hub/jquery_controller.js`
- [x] T024 [US3] Update integration regression assertions for existing actions compatibility in `spec/integration/broadcast_hub/dispatch_flow_spec.rb`
- [x] T025 [US3] Update integration safety assertions for invalid `replace` payload behavior in `spec/integration/broadcast_hub/dispatch_flow_spec.rb`
- [x] T026 [US3] Run focused US3 specs in `spec/services/broadcast_hub/payload_builder_spec.rb` and `spec/integration/broadcast_hub/dispatch_flow_spec.rb`

**Checkpoint**: Validation and compatibility guarantees are enforced by tests.

---

## Phase 6: Polish & Cross-Cutting Concerns

**Purpose**: Finalize docs and full verification gates.

- [x] T027 [P] Update public action documentation and examples in `README.md`
- [x] T028 [P] Sync quickstart execution notes in `specs/001-add-broadcast-action/quickstart.md`
- [x] T029 Run lint verification with `bundle exec rubocop` from repository root
- [x] T030 Run full regression verification with `bundle exec rspec` from repository root

---

## Phase 7: Coverage Gap Closure

**Purpose**: Address coverage-review gaps and task-quality findings before implementation handoff.

- [x] T031 [P] [US3] Add failing mismatch-id safety case in `spec/javascripts/broadcast_hub/jquery_controller_spec.rb`
- [x] T032 [US3] Add failing divergent-client-state scenario in `spec/integration/broadcast_hub/dispatch_flow_spec.rb`
- [x] T033 [P] [US3] Add non-regression authorization/scope coverage for `replace` in `spec/channels/broadcast_hub/stream_channel_spec.rb`
- [x] T034 [US3] Add manual-flow-elimination acceptance checklist in `specs/001-add-broadcast-action/quickstart.md`
- [x] T035 [US1] Add explicit "when NOT to use replace" guidance in `specs/001-add-broadcast-action/research.md`
- [x] T036 [P] [US2] Add missing-target no-op test case for `replace` in `spec/javascripts/broadcast_hub/jquery_controller_spec.rb`
- [x] T037 [US3] Add <=15-minute validation checklist for integrator setup in `specs/001-add-broadcast-action/quickstart.md`
- [ ] T038 Create completion commit by staging `app/services/broadcast_hub/payload_builder.rb`, `app/controllers/concerns/broadcast_hub/controller_helpers.rb`, `app/models/concerns/broadcast_hub/broadcaster.rb`, `app/javascripts/broadcast_hub/jquery_controller.js`, `spec/services/broadcast_hub/payload_builder_spec.rb`, `spec/controllers/broadcast_hub/controller_helpers_spec.rb`, `spec/models/concerns/broadcast_hub/broadcaster_spec.rb`, `spec/javascripts/broadcast_hub/jquery_controller_spec.rb`, `spec/integration/broadcast_hub/dispatch_flow_spec.rb`, `spec/channels/broadcast_hub/stream_channel_spec.rb`, `README.md`, `specs/001-add-broadcast-action/research.md`, and `specs/001-add-broadcast-action/quickstart.md` from repository root and running `git commit`

---

## Dependencies & Execution Order

### Phase Dependencies

- Setup (Phase 1): can start immediately.
- Foundational (Phase 2): depends on Setup; blocks all user stories.
- User Story phases (Phase 3-5): depend on Foundational completion.
- Polish (Phase 6): depends on completion of desired user stories.
- Coverage Gap Closure (Phase 7): depends on completion of story phases and should complete before implementation handoff.

### User Story Dependencies

- **US1 (P1)**: starts after Phase 2; no dependency on US2/US3.
- **US2 (P2)**: starts after Phase 2; depends on core enum/validation support from Phase 2.
- **US3 (P3)**: starts after Phase 2; validates hardened behavior from US1/US2.

### Within Each User Story

- Write failing tests first.
- Implement minimal behavior to satisfy tests.
- Run focused specs for that story before progressing.

### Parallel Opportunities

- T002 and T003 can run in parallel.
- T006, T007, and T008 can run in parallel after T004/T005.
- In US1, T009 and T010 can run in parallel.
- In US2, T015 and T016 can run in parallel.
- In US3, T021 and T022 can run in parallel.
- In Polish, T027 and T028 can run in parallel before T029/T030.
- In Coverage Gap Closure, T031, T033, and T036 can run in parallel.

---

## Parallel Example: User Story 1

```bash
Task: "T009 [US1] Add failing contract examples in spec/services/broadcast_hub/payload_builder_spec.rb"
Task: "T010 [US1] Add failing helper allowlist specs in spec/controllers/broadcast_hub/controller_helpers_spec.rb"
```

## Parallel Example: User Story 2

```bash
Task: "T015 [US2] Add failing runtime behavior specs in spec/javascripts/broadcast_hub/jquery_controller_spec.rb"
Task: "T016 [US2] Add failing broadcaster flow specs in spec/models/concerns/broadcast_hub/broadcaster_spec.rb"
```

## Parallel Example: User Story 3

```bash
Task: "T021 [US3] Add failing invalid payload cases in spec/services/broadcast_hub/payload_builder_spec.rb"
Task: "T022 [US3] Add failing integration regression coverage in spec/integration/broadcast_hub/dispatch_flow_spec.rb"
```

---

## Implementation Strategy

### MVP First (User Story 1 Only)

1. Complete Phase 1 and Phase 2.
2. Complete Phase 3 (US1).
3. Validate focused US1 specs.
4. Review contract + recommendation docs.

### Incremental Delivery

1. Deliver US1 (contract + recommendation baseline).
2. Deliver US2 (`replace` runtime and broadcaster behavior).
3. Deliver US3 (hardening + regression guarantees).
4. Finalize with Phase 6 docs and full verification.

### Parallel Team Strategy

1. One developer completes Phase 1-2.
2. Then split by story:
   - Developer A: US1
   - Developer B: US2
   - Developer C: US3
3. Rejoin for Phase 6 verification and docs.

---

## Notes

- All tasks follow required checklist format: `- [ ] T### [P?] [US?] Description with file path`.
- Story labels are applied only to user story phases.
- Each user story includes explicit independent test criteria.
- Suggested MVP scope: Phase 1 + Phase 2 + Phase 3 (US1).
