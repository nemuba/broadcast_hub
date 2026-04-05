# Payload Contract Delta: `replace` Action

## Scope

This contract describes the incremental payload change required to add `replace` action
support while preserving all existing action behavior.

## Updated Action Enum

- Before: `append | prepend | update | remove | dispatch`
- After: `append | prepend | update | replace | remove | dispatch`

## Field Rules

- `action`: MUST be `replace` for this flow.
- `target`: REQUIRED and non-blank.
- `content`: REQUIRED and non-blank.
- `id`: REQUIRED by engine payload contract (existing global rule).
- `meta`: OPTIONAL hash (defaults to `{}`).
- `event_name`: MUST be omitted.
- `event_data`: MUST be omitted.

## Example Payload

```json
{
  "version": "v1",
  "action": "replace",
  "target": "#todo_42",
  "content": "<li id=\"todo_42\" class=\"todo done\">Ship feature</li>",
  "id": "todo_42",
  "meta": {}
}
```

## Runtime Semantics

- Client resolves `target` selector.
- For `replace`, matched target element(s) are replaced with `content`.
- If no element matches, behavior is safe no-op.
- Invalid payloads remain ignored at runtime guard layer (development warning path unchanged).

## Compatibility Guarantees

- Existing actions continue with unchanged semantics.
- Authorization and stream key resolution are unchanged.
- Dispatch-only fields (`event_name`, `event_data`) remain exclusive to `dispatch`.
