# BroadcastHub

BroadcastHub is a reusable Action Cable broadcasting layer for Rails 5/6 apps that use server-rendered HTML and Sprockets. It replaces model-level Turbo stream helpers with an explicit payload contract sent over `BroadcastHub::StreamChannel`.

## 1) What BroadcastHub is

- Rails engine (`broadcast_hub`) scoped to Rails `>= 5.2`, `< 7.0`
- Server concern (`BroadcastHub::Broadcaster`) for model callbacks and payload publishing
- Generic Action Cable channel (`BroadcastHub::StreamChannel`) with authorization and stream key resolution
- Browser helpers (`BroadcastHub.Subscription` and `BroadcastHub.JQueryController`) for applying append/prepend/update/remove/dispatch actions

BroadcastHub is designed to work without `turbo-rails`.

## 2) Installation in host app

Add the engine gem to the host app `Gemfile`:

```ruby
gem 'broadcast_hub', '~> 0.2.1'
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

## 5) Controller helper integration

For controller-triggered realtime updates (for example action-specific highlight/flash events), use `render_broadcast`.

```ruby
class TodosController < ApplicationController
  def highlight
    respond_to do |format|
      format.js { broadcast_todo_highlight }
      format.json { broadcast_todo_highlight }
    end
  end

  private

  def broadcast_todo_highlight
    render_broadcast(
      action: 'dispatch',
      target: "#todo_#{params[:id]}",
      resource: 'todo',
      event_name: 'todo:highlight',
      event_data: { id: params[:id] }
    )
  end
end
```

`render_broadcast` options:

- Required: `action`, `target`, `resource`
- For `append|prepend|update`: `partial` is required
- For `remove|dispatch`: `content` is forced to `nil`
- For `dispatch`: `event_name` is required and `event_data` must be a hash when provided
- `id` defaults to a generated UUID when omitted
- Stream authorization/identity is resolved through `BroadcastHub::StreamKeyResolver.resolve!` using `BroadcastHub::StreamKeyContext`

## 6) Client-side integration (Sprockets)

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

## 7) Payload contract

Payloads emitted by `BroadcastHub::PayloadBuilder` follow this contract:

```json
{
  "version": 1,
  "action": "append",
  "target": "#todos",
  "content": "<div id=\"todo_1\">...</div>",
  "id": "todo_1",
  "meta": {}
}
```

Dispatch actions extend this payload with event fields:

```json
{
  "version": 1,
  "action": "dispatch",
  "target": "#todos",
  "content": null,
  "id": "todo_1",
  "meta": {},
  "event_name": "todo:highlight",
  "event_data": { "id": "todo_1" }
}
```

Field meaning:

- `action`: one of `append`, `prepend`, `update`, `remove`, `dispatch`
- `target`: CSS selector used as insertion/update/remove/dispatch target
- `content`: rendered HTML for append/prepend/update (typically `null` on remove/dispatch)
- `id`: DOM id used by update/remove fast-path replacement
- `meta`: optional metadata hash (defaults to `{}`)
- `event_name`: required when `action` is `dispatch`; event name passed to jQuery `trigger`
- `event_data`: optional hash payload for `dispatch`; delivered as trigger argument data
- `version`: payload contract version from `BroadcastHub.configuration.payload_version`

Dispatch-specific notes:

- `event_name` and `event_data` are included only when `action` is `dispatch`
- `event_data` must be a hash when provided
