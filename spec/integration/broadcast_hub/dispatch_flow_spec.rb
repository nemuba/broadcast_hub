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

  it 'broadcasts replace payload without dispatch-only fields' do
    BroadcastHub.configure do |config|
      config.allowed_resources = [ 'todo' ]
      config.authorize_scope = ->(_context) { true }
      config.stream_key_resolver = lambda do |context|
        "resource:#{context.resource_name}:user:#{context.current_user.id}"
      end
    end

    allow(ActionCable.server).to receive(:broadcast)

    user = create(:user)
    todo = create(:todo, user_id: user.id)
    rendered_content = '<li id="todo_1">Updated task</li>'

    allow(todo).to receive(:render_broadcast_content).and_return(rendered_content)

    expect(ActionCable.server).to receive(:broadcast).with(
      "resource:todo:user:#{user.id}",
      hash_including(
        action: 'replace',
        target: '#todos',
        content: rendered_content,
        id: "todo_#{todo.id}"
      )
    ).once

    todo.broadcast_replace('#todos')
  end

  it 'raises validation error for replace payload with blank content' do
    BroadcastHub.configure do |config|
      config.allowed_resources = [ 'todo' ]
      config.authorize_scope = ->(_context) { true }
      config.stream_key_resolver = lambda do |context|
        "resource:#{context.resource_name}:user:#{context.current_user.id}"
      end
    end

    user = create(:user)
    todo = create(:todo, user_id: user.id)

    allow(todo).to receive(:render_broadcast_content).and_return(' ')
    allow(ActionCable.server).to receive(:broadcast)

    expect do
      todo.broadcast_replace('#todos')
    end.to raise_error(BroadcastHub::PayloadBuilder::ValidationError, 'content required')

    expect(ActionCable.server).not_to have_received(:broadcast)
  end
end
