<!--
Sync Impact Report
- Version change: template placeholder -> 1.0.0
- Modified principles:
  - Template Principle 1 -> I. Contract-First Payload Integrity
  - Template Principle 2 -> II. Authorized and Scoped Streaming
  - Template Principle 3 -> III. Test-First Change Safety (NON-NEGOTIABLE)
  - Template Principle 4 -> IV. Engine Boundary and Service Isolation
  - Template Principle 5 -> V. Documentation and Verification Gates
- Added sections:
  - Engineering Constraints
  - Development Workflow and Quality Gates
- Removed sections: None
- Templates requiring updates:
  - ✅ .specify/templates/plan-template.md
  - ✅ .specify/templates/spec-template.md
  - ✅ .specify/templates/tasks-template.md
  - ⚠ pending: .specify/templates/commands/*.md (directory not present)
  - ✅ README.md (reviewed; no constitution reference changes required)
  - ✅ AGENTS.md (reviewed; already aligned)
- Follow-up TODOs: None
-->

# BroadcastHub Constitution

## Core Principles

### I. Contract-First Payload Integrity
All realtime message producers and consumers MUST follow a single payload contract owned
by `BroadcastHub::PayloadBuilder`. Allowed actions are `append`, `prepend`, `update`,
`remove`, and `dispatch`. `content` MUST be present for `append|prepend|update` and MUST
be `nil` for `remove|dispatch`; `dispatch` MUST include `event_name`; `event_data`, when
provided, MUST be a hash. Any contract change MUST update Ruby, JavaScript, and
documentation in the same change.

Rationale: BroadcastHub is a contract-driven engine; drift between emitter and client
breaks live updates and is difficult to debug after release.

### II. Authorized and Scoped Streaming
Every subscription MUST be authorized with `BroadcastHub.configuration.authorize_scope`
before streaming, and every stream key MUST be resolved through
`BroadcastHub.configuration.stream_key_resolver`. Resource access MUST be constrained by
`allowed_resources`; no direct or implicit bypass is permitted.

Rationale: Streaming is a data distribution boundary. Explicit authorization and stable
stream scoping prevent accidental cross-tenant or cross-user data exposure.

### III. Test-First Change Safety (NON-NEGOTIABLE)
Behavior changes MUST start with failing tests that express the expected outcome before
implementation. New or changed payload behavior MUST include contract-level specs. Changes
that touch channel authorization, controller helpers, or JavaScript DOM application MUST
include focused integration coverage in the same pull request.

Rationale: BroadcastHub spans server, transport, and browser runtimes; only test-first
workflows consistently prevent regressions across those boundaries.

### IV. Engine Boundary and Service Isolation
Business rules MUST live in service objects or focused domain modules under the
`BroadcastHub` namespace. Controllers MUST stay thin, and models MUST avoid complex
cross-cutting logic beyond persistence and basic validation. Cross-engine data access MUST
go through explicit interfaces, never implicit table coupling.

Rationale: Clear boundaries keep this engine reusable and predictable across host apps,
while reducing hidden coupling and maintenance risk.

### V. Documentation and Verification Gates
Any change to public behavior, contract shape, setup flow, or developer ergonomics MUST
update user-facing documentation (`README.md`) and API docs (YARD/RDoc when applicable) in
the same change. Before completion, contributors MUST run relevant focused specs and SHOULD
run the full suite and RuboCop from repository root; unresolved unrelated failures MUST be
explicitly reported.

Rationale: The engine is consumed by other teams and apps; accurate docs and reproducible
verification are part of the deliverable, not optional follow-up work.

## Engineering Constraints

- Ruby files MUST begin with `# frozen_string_literal: true`.
- Public constants and schemas SHOULD be immutable (`.freeze`) when they define stable
  contract values.
- Input validation MUST happen before side effects in Ruby services and JavaScript
  controllers.
- Security posture is mandatory: no hardcoded secrets, no unsanitized external input,
  no SQL interpolation, and no sensitive data logging.
- Architecture MUST favor simple, explicit composition over metaprogramming and implicit
  callbacks unless a justified exception is documented.

## Development Workflow and Quality Gates

- Plans and tasks MUST include an explicit constitution compliance check.
- Feature specs MUST define independently testable user stories, measurable outcomes,
  and assumptions.
- Task plans MUST include tests for each story that changes behavior; test tasks are
  required, not optional.
- Pull requests MUST state how each impacted principle was validated (tests, docs,
  security/authorization checks, and integration coverage where applicable).
- Completion claims MUST be backed by command evidence from this repository root.

## Governance

This constitution overrides informal local practices for this repository. Amendments MUST
be submitted as documented pull requests that include: (1) proposed text, (2) rationale,
(3) migration/impact notes for templates and workflows, and (4) updated verification
expectations where needed.

Versioning policy for this constitution uses semantic versioning:
- MAJOR: Backward-incompatible governance changes, principle removals, or principle
  redefinitions.
- MINOR: New principles/sections or materially expanded mandatory guidance.
- PATCH: Clarifications, wording refinements, typo fixes, and non-semantic edits.

Compliance review is required for every implementation PR and every planning artifact that
uses `.specify` templates. Reviewers MUST block merges when constitutional violations are
unresolved or not explicitly accepted with rationale.

**Version**: 1.0.0 | **Ratified**: 2026-04-05 | **Last Amended**: 2026-04-05
