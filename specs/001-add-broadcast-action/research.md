# Phase 0 Research - Add `replace` Broadcast Action

## Decision 1: New action should be `replace`

- Decision: Adopt `replace` as the new action to perform full target element replacement in
  one operation.
- Rationale: Existing actions cover insertion (`append`, `prepend`), partial/ID-aware update
  (`update`), removal (`remove`), and event signaling (`dispatch`), but none express
  explicit full replacement intent for an existing target node.
- Alternatives considered:
  - `refresh`: rejected because it implies data re-fetch semantics, not deterministic DOM
    replacement.
  - Reuse `update` only: rejected because current `update` has dual behavior
    (`replaceWith` when `id` exists, `html` fallback otherwise), making full-replacement
    intent less explicit at API level.

## Decision 2: `replace` should require `content`

- Decision: Treat `replace` as a content-required action, same validation category as
  `append`, `prepend`, and `update`.
- Rationale: A replacement without content is invalid by definition and should fail fast in
  payload validation.
- Alternatives considered:
  - Allow empty content as no-op: rejected due to ambiguous behavior and silent failures.
  - Reclassify as content-optional: rejected because it weakens contract clarity.

## Decision 3: Runtime behavior should be deterministic and target-scoped

- Decision: In JavaScript runtime, `replace` will operate on `$target` and replace matched
  target element(s) with provided content.
- Rationale: Aligns with user story focused on full block replacement and avoids hidden
  fallback paths that blur behavior.
- Alternatives considered:
  - ID-first replacement fallback (like `update`): rejected for this action because the
    semantic target is already explicit and should not depend on optional `id` heuristics.
  - Trigger custom event instead of replacement: rejected because `dispatch` already owns
    event signaling.

## Decision 4: No authorization or stream-key changes

- Decision: Keep subscription authorization and stream key resolution untouched.
- Rationale: Action expansion changes payload contract only, not stream boundary or tenant
  scoping.
- Alternatives considered:
  - Action-specific authorization branch: rejected as unnecessary complexity without security
    benefit for this feature.

## Decision 5: Coverage must span contract + runtime + docs

- Decision: Add fail-first tests in payload builder, broadcaster concern, controller helper,
  jQuery controller, and integration path where applicable; update README and public method
  docs in the same change.
- Rationale: Constitution requires contract parity and test-first safety across Ruby and
  JavaScript boundaries.
- Alternatives considered:
  - Unit-only tests: rejected; insufficient for cross-runtime behavior.
  - Docs in follow-up PR: rejected; violates documentation gate.

## When NOT to use `replace`

- Do not use `replace` when you only need incremental insertion (`append`/`prepend`).
- Do not use `replace` when update semantics need id-first fallback behavior (`update`).
- Do not use `replace` for event signaling; keep event-driven flows on `dispatch`.
- Do not use `replace` with uncertain target selectors; prefer explicit target validation
  and no-op-safe handling when the client view may be stale.
