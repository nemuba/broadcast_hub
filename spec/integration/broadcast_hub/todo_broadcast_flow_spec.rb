# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Todo BroadcastHub flow', type: :model do
  around do |example|
    original_configuration = BroadcastHub.configuration
    BroadcastHub.configuration = BroadcastHub::Configuration.new
    example.run
  ensure
    BroadcastHub.configuration = original_configuration
  end

  it 'broadcasts create payload to a user-scoped stream key' do
    captured_context = nil

    BroadcastHub.configure do |config|
      config.allowed_resources = [ 'todo' ]
      config.authorize_scope = ->(_context) { true }
      config.stream_key_resolver = lambda do |context|
        captured_context = context
        "resource:#{context.resource_name}:user:#{context.current_user.id}"
      end
    end

    renderer = instance_double(BroadcastHub::Renderer, render: "<li id='todo_123'>Task</li>")
    allow(BroadcastHub::Renderer).to receive(:new).and_return(renderer)
    allow(ActionCable.server).to receive(:broadcast)

    user = create(:user)
    todo = create(:todo, :with_user, user_id: user.id)

    expect(captured_context).to be_a(BroadcastHub::StreamKeyContext)
    expect(captured_context.resource_name).to eq('todo')
    expect(captured_context.current_user).to eq(user)

    expect(ActionCable.server).to have_received(:broadcast).with(
      "resource:todo:user:#{user.id}",
      hash_including(
        action: 'append',
        target: '#todos',
        id: "todo_#{todo.id}"
      )
    )
  end
end
