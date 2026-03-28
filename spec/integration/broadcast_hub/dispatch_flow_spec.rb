# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'BroadcastHub dispatch flow', type: :model do
  around do |example|
    original_configuration = BroadcastHub.configuration
    BroadcastHub.configuration = BroadcastHub::Configuration.new
    example.run
  ensure
    BroadcastHub.configuration = original_configuration
  end

  it 'broadcasts dispatch payload with event details to a user-scoped stream key' do
    captured_context = nil

    BroadcastHub.configure do |config|
      config.allowed_resources = [ 'todo' ]
      config.authorize_scope = ->(_context) { true }
      config.stream_key_resolver = lambda do |context|
        captured_context = context
        "resource:#{context.resource_name}:user:#{context.current_user.id}"
      end
    end

    allow(ActionCable.server).to receive(:broadcast)

    user = create(:user)
    todo = create(:todo, user_id: user.id)
    event_name = 'todo:highlight'
    event_data = { todo_id: todo.id, urgent: true }

    expect(ActionCable.server).to receive(:broadcast).with(
      "resource:todo:user:#{user.id}",
      {
        version: 1,
        action: 'dispatch',
        target: '#todos',
        content: nil,
        id: "todo_#{todo.id}",
        meta: {},
        event_name: event_name,
        event_data: event_data
      }
    ).once

    todo.broadcast_dispatch('#todos', event_name, event_data)

    expect(captured_context).to be_a(BroadcastHub::StreamKeyContext)
    expect(captured_context.resource_name).to eq('todo')
    expect(captured_context.current_user).to eq(user)
  end
end
