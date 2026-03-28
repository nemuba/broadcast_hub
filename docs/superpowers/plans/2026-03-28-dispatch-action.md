# `dispatch` Action Implementation Plan

> **For agentic workers:** REQUIRED: Use superpowers:subagent-driven-development (if subagents available) or superpowers:executing-plans to implement this plan. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Implement the `dispatch` action in `broadcast_hub` to trigger client-side events via Action Cable.

**Architecture:** Add `dispatch` support to `PayloadBuilder` (validation), `Broadcaster` (Ruby helper), and `JQueryController` (client-side execution).

**Tech Stack:** Rails, RSpec, Action Cable, jQuery.

---

## Chunk 1: Backend Implementation

### Task 1.1: Enhance `PayloadBuilder`

**Files:**
- Modify: `app/services/broadcast_hub/payload_builder.rb`
- Create: `spec/services/broadcast_hub/payload_builder_spec.rb`

- [ ] **Step 1: Write failing tests for `PayloadBuilder.build` with `dispatch`**

```ruby
# frozen_string_literal: true

require 'rails_helper'

RSpec.describe BroadcastHub::PayloadBuilder do
  describe '.build' do
    it 'requires event_name for dispatch action' do
      expect {
        described_class.build(action: 'dispatch', target: '#user', content: nil, id: '1')
      }.to raise_error(BroadcastHub::PayloadBuilder::ValidationError, "event_name required for dispatch action")
    end

    it 'includes event_name and event_data in the payload' do
      payload = described_class.build(
        action: 'dispatch',
        target: '#user',
        content: nil,
        id: '1',
        event_name: 'test_event',
        event_data: { foo: 'bar' }
      )

      expect(payload[:event_name]).to eq('test_event')
      expect(payload[:event_data]).to eq({ foo: 'bar' })
    end
  end
end
```

- [ ] **Step 2: Run tests to verify they fail**

Run: `bundle exec rspec spec/services/broadcast_hub/payload_builder_spec.rb`

- [ ] **Step 3: Update `PayloadBuilder` constants and logic**

```ruby
# app/services/broadcast_hub/payload_builder.rb

VALID_ACTIONS = %w[append prepend update remove dispatch].freeze
ACTIONS_REQUIRING_CONTENT = %w[append prepend update].freeze
ALLOWED_KEYS = %i[version action target content id meta event_name event_data].freeze

def build(action:, target:, content:, id:, meta: {}, event_name: nil, event_data: {})
  validate_action!(action)
  validate_target!(target)
  validate_content!(action, content)
  validate_dispatch!(action, event_name) if action == 'dispatch'

  payload = {
    version: BroadcastHub.configuration.payload_version,
    action: action,
    target: target,
    content: content,
    id: id,
    meta: normalize_meta(meta),
    event_name: event_name,
    event_data: event_data
  }

  payload.slice(*ALLOWED_KEYS)
end

private

def validate_dispatch!(action, event_name)
  raise ValidationError, "event_name required for dispatch action" if event_name.to_s.strip.empty?
end
```

- [ ] **Step 4: Run tests to verify they pass**

- [ ] **Step 5: Commit**

### Task 1.2: Enhance `Broadcaster`

**Files:**
- Modify: `app/models/concerns/broadcast_hub/broadcaster.rb`
- Create: `spec/models/concerns/broadcast_hub/broadcaster_spec.rb`

- [ ] **Step 1: Write failing test for `broadcast_dispatch`**

```ruby
# frozen_string_literal: true

require 'rails_helper'

RSpec.describe BroadcastHub::Broadcaster, type: :model do
  let(:test_class) do
    Class.new do
      include BroadcastHub::Broadcaster
      def self.model_name
        ActiveModel::Name.new(self, nil, "TestModel")
      end
      def id; 1; end
      def broadcast_hub_resource_name; "test_resource"; end
    end
  end
  let(:instance) { test_class.new }

  describe '#broadcast_dispatch' do
    it 'broadcasts dispatch action with event_name and event_data' do
      allow(ActionCable.server).to receive(:broadcast)
      allow(BroadcastHub.configuration).to receive(:stream_key_resolver).and_return(->(_) { "test_stream" })

      instance.broadcast_dispatch("#target", "test_event", { foo: "bar" })

      expect(ActionCable.server).to have_received(:broadcast).with(
        "test_stream",
        hash_including(
          action: "dispatch",
          target: "#target",
          event_name: "test_event",
          event_data: { foo: "bar" }
        )
      )
    end
  end
end
```

- [ ] **Step 2: Run tests to verify they fail**

- [ ] **Step 3: Update `Broadcaster` concern**

```ruby
# app/models/concerns/broadcast_hub/broadcaster.rb

def broadcast_dispatch(target, event_name, event_data = {})
  broadcast_action("dispatch", target, event_name: event_name, event_data: event_data)
end

private

def broadcast_action(action, target, event_name: nil, event_data: {})
  content = %w[remove dispatch].include?(action) ? nil : render_broadcast_content
  payload = BroadcastHub::PayloadBuilder.build(
    action: action,
    target: target,
    content: content,
    id: broadcast_hub_dom_id,
    meta: {},
    event_name: event_name,
    event_data: event_data
  )

  ActionCable.server.broadcast(broadcast_hub_stream_key, payload)
end
```

- [ ] **Step 4: Run tests to verify they pass**

- [ ] **Step 5: Commit**

---

## Chunk 2: Frontend Implementation

### Task 2.1: Update `JQueryController`

**Files:**
- Modify: `app/javascripts/broadcast_hub/jquery_controller.js`

- [ ] **Step 1: Update `apply` method**

```javascript
// app/javascripts/broadcast_hub/jquery_controller.js

apply(payload) {
  const action = payload && payload.action;
  const targetSelector = payload && payload.target;
  const content = payload && payload.content;
  const id = payload && payload.id;
  const eventName = payload && payload.event_name;
  const eventData = payload && payload.event_data;

  if (!this._isValidPayload(action, targetSelector, content, eventName)) {
    this._warnInvalidPayload();
    return;
  }
  // ...
  switch (action) {
    // ...
    case 'dispatch':
      this.$(targetSelector).trigger(eventName, [eventData]);
      return;
    // ...
  }
}
```

- [ ] **Step 2: Update `_isValidPayload`**

```javascript
// app/javascripts/broadcast_hub/jquery_controller.js

_isValidPayload(action, targetSelector, content, eventName) {
  if (isBlank(action) || isBlank(targetSelector)) {
    return false;
  }

  if ((action === 'append' || action === 'prepend' || action === 'update') && isBlank(content)) {
    return false;
  }

  if (action === 'dispatch' && isBlank(eventName)) {
    return false;
  }

  return true;
}
```

- [ ] **Step 3: Commit**

---

## Chunk 3: Final Verification

### Task 3.1: Integration Test

**Files:**
- Create: `spec/integration/broadcast_hub/dispatch_flow_spec.rb`

- [ ] **Step 1: Write integration test for the full `dispatch` flow**

```ruby
# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Dispatch flow', type: :model do
  around do |example|
    original_configuration = BroadcastHub.configuration
    BroadcastHub.configuration = BroadcastHub::Configuration.new
    example.run
  ensure
    BroadcastHub.configuration = original_configuration
  end

  it 'broadcasts dispatch payload' do
    BroadcastHub.configure do |config|
      config.allowed_resources = [ 'todo' ]
      config.authorize_scope = ->(_context) { true }
      config.stream_key_resolver = ->(context) { "resource:#{context.resource_name}" }
    end

    allow(ActionCable.server).to receive(:broadcast)

    user = create(:user)
    todo = create(:todo, user: user)

    todo.broadcast_dispatch("#todos", "todo_updated", { id: todo.id })

    expect(ActionCable.server).to have_received(:broadcast).with(
      "resource:todo",
      hash_including(
        action: 'dispatch',
        target: '#todos',
        event_name: 'todo_updated',
        event_data: { id: todo.id }
      )
    )
  end
end
```

- [ ] **Step 2: Run all tests**
- [ ] **Step 3: Commit**
