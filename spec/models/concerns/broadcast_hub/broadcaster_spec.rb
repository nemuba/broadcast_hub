# frozen_string_literal: true

require "rails_helper"

RSpec.describe BroadcastHub::Broadcaster, type: :model do
  around do |example|
    original_configuration = BroadcastHub.configuration
    BroadcastHub.configuration = BroadcastHub::Configuration.new
    example.run
  ensure
    BroadcastHub.configuration = original_configuration
  end

  describe "#broadcast_dispatch" do
    it "broadcasts a dispatch payload with event details" do
      BroadcastHub.configure do |config|
        config.allowed_resources = [ "todo" ]
        config.authorize_scope = ->(_context) { true }
        config.stream_key_resolver = ->(_context) { "resource:todo:user:1" }
      end

      todo = create(:todo, :with_user)

      allow(ActionCable.server).to receive(:broadcast)

      event_name = "todo:highlight"
      event_data = { todo_id: todo.id, urgent: true }

      todo.broadcast_dispatch("#todos", event_name, event_data)

      expect(ActionCable.server).to have_received(:broadcast).with(
        "resource:todo:user:1",
        hash_including(
          action: "dispatch",
          target: "#todos",
          content: nil,
          event_name: event_name,
          event_data: event_data,
          id: "todo_#{todo.id}"
        )
      )
    end
  end
end
