# Design Spec: `dispatch` Action for BroadcastHub
**Date**: 2026-03-28
**Status**: Draft

## 1. Problem Statement
The `broadcast_hub` gem is currently limited to DOM manipulations (`append`, `prepend`, `update`, `remove`). It lacks a mechanism to trigger arbitrary client-side events or logic that isn't purely about HTML injection.

## 2. Proposed Solution
Introduce a `dispatch` action that uses jQuery's `.trigger()` method to fire events on a target DOM element, passing optional data.

## 3. Changes required

### 3.1. Payload Contract (JSON)
Two new fields added to the payload:
- `event_name` (String): The name of the event to be triggered.
- `event_data` (Hash): Arbitrary data passed as the second argument to jQuery's `.trigger()`.

Example payload:
```json
{
  "version": 1,
  "action": "dispatch",
  "target": "#user_1",
  "event_name": "profile_updated",
  "event_data": { "status": "active" }
}
```

### 3.2. Backend (Ruby)

#### `BroadcastHub::PayloadBuilder`
- Add `dispatch` to `VALID_ACTIONS`.
- Add `event_name` and `event_data` to `ALLOWED_KEYS`.
- Validate `event_name` presence when `action` is `dispatch`.

#### `BroadcastHub::Broadcaster`
- Add `broadcast_dispatch(target, event_name, event_data = {})` method.
- Update `broadcast_action` to handle `dispatch` and pass `event_name`/`event_data`.

### 3.3. Frontend (JavaScript)

#### `BroadcastHubJQueryController`
- Add `dispatch` case to the `switch` in `apply(payload)`.
- Use `this.$(targetSelector).trigger(payload.event_name, [payload.event_data])`.
- Update `_isValidPayload` to check `event_name` for `dispatch` actions.

## 4. Error Handling
- Invalid `event_name` will trigger the standard `_warnInvalidPayload` in development.
- Payload builder will raise `ValidationError` if required fields are missing.

## 5. Testing Plan
- **Backend**: RSpec tests in `broadcaster_spec.rb` and `payload_builder_spec.rb` for the new action.
- **Frontend**: Manual/Dummy app verification of event triggering.
- **Contract**: Verify JSON output includes new keys.
