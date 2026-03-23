# BroadcastHub

BroadcastHub is a reusable Action Cable broadcasting layer for Rails 5/6 apps that use server-rendered HTML and Sprockets. It replaces model-level Turbo stream helpers with an explicit payload contract sent over `BroadcastHub::StreamChannel`.

## 1) What BroadcastHub is

- Rails engine (`broadcast_hub`) scoped to Rails `>= 5.2`, `< 7.0`
- Server concern (`BroadcastHub::Broadcaster`) for model callbacks and payload publishing
- Generic Action Cable channel (`BroadcastHub::StreamChannel`) with authorization and stream key resolution
- Browser helpers (`BroadcastHub.Subscription` and `BroadcastHub.JQueryController`) for applying append/prepend/update/remove actions

BroadcastHub is designed to work without `turbo-rails`.

## 2) Installation in host app

Add the engine gem to the host app `Gemfile`:

```ruby
gem 'broadcast_hub', path: 'engines/broadcast_hub'
```

Install dependencies, then generate the initializer template:

```bash
bundle install
bin/rails generate broadcast_hub:install
```

This creates `config/initializers/broadcast_hub.rb`.

## 3) Initializer configuration

Minimum required settings:

- `allowed_resources`: allowlist of resource keys clients can subscribe to
- `authorize_scope`: lambda that decides if the Action Cable connection can subscribe
- `stream_key_resolver`: lambda that maps subscription context to a stream name used by both channel + model broadcaster

Authenticated example:

```ruby
BroadcastHub.configure do |config|
  config.allowed_resources = %w[todo]

  config.authorize_scope = lambda do |context|
    context.current_user.present?
  end

  config.stream_key_resolver = lambda do |context|
    "resource:#{context.resource_name}:user:#{context.current_user.id}"
  end
end
```

No-auth/session example:

```ruby
BroadcastHub.configure do |config|
  config.allowed_resources = %w[todo]

  config.authorize_scope = lambda do |context|
    context.session_id.present?
  end

  config.stream_key_resolver = lambda do |context|
    "resource:#{context.resource_name}:session:#{context.session_id}"
  end
end
```

If your Action Cable connection does not expose `current_user`, expose a safe identifier (for example `session_id`) in `ApplicationCable::Connection`.

## 4) Model integration

Include the concern and declare broadcast settings in each model:

```ruby
class Todo < ApplicationRecord
  include BroadcastHub::Broadcaster

  broadcast_to :todo, partial: 'todos/partials/todo', target: '#todos'
end
```

`broadcast_to` wires callbacks:

- `after_create_commit` -> append
- `after_update_commit` -> update
- `after_destroy_commit` -> remove

Optional context hook for stream-key alignment (recommended when keys depend on tenant/user/session):

```ruby
def broadcast_hub_stream_key_context_attributes
  {
    tenant_id: nil,
    current_user: user,
    session_id: nil,
    params: {}
  }
end
```

## 5) Client-side integration (Sprockets)

Require BroadcastHub in `app/assets/javascripts/application.js`:

```js
//= require broadcast_hub/index
```

Basic subscription wiring (compatible with this repo style):

```js
(function (global) {
  function wireTodoChannel(consumer, $) {
    var controller = new BroadcastHubJQueryController($);
    var subscription = new BroadcastHubSubscription(consumer, controller);

    return subscription.subscribe('todo');
  }

  if (global.App && global.App.cable && global.jQuery) {
    global.App.todo_channel = wireTodoChannel(global.App.cable, global.jQuery);
  }
})(this);
```

`BroadcastHubSubscription` sends `{ channel: 'BroadcastHub::StreamChannel', resource: 'todo' }` and the controller applies incoming payloads to the DOM.

## 6) Payload contract

Payloads emitted by `BroadcastHub::PayloadBuilder` follow this shape:

```json
{
  "version": 1,
  "action": "append",
  "target": "#todos",
  "content": "<div id=\"todo_1\">...</div>",
  "id": "todo_1"
}
```

Field meaning:

- `action`: one of `append`, `prepend`, `update`, `remove`
- `target`: CSS selector used as insertion/update/remove target
- `content`: rendered HTML for append/prepend/update (typically `null` on remove)
- `id`: DOM id used by update/remove fast-path replacement
- `version`: payload contract version from `BroadcastHub.configuration.payload_version`

## 7) Migration note for legacy `Broadcaster` concern

For apps migrating from a legacy concern (`app/models/concerns/broadcaster.rb`):

1. Disable new usage of the legacy concern first (stop adding `include Broadcaster` to new/changed models).
2. Move models to `include BroadcastHub::Broadcaster` with explicit `broadcast_to` options.
3. Keep temporary compatibility shims only while channels/clients are being switched.
4. Remove the legacy concern and shims after all models and consumers are on BroadcastHub.

This staged approach prevents mixed stream contracts during rollout.
