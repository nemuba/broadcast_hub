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

  describe "broadcast helpers" do
    let(:todo) { create(:todo, :with_user) }

    before do
      BroadcastHub.configure do |config|
        config.allowed_resources = [ "todo" ]
        config.authorize_scope = ->(_context) { true }
        config.stream_key_resolver = ->(_context) { "resource:todo:user:1" }
      end

      allow(ActionCable.server).to receive(:broadcast)
    end

    it "broadcast_dispatch skips content rendering and includes event details" do
      event_name = "todo:highlight"
      event_data = { todo_id: todo.id, urgent: true }

      expect(todo).not_to receive(:render_broadcast_content)

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

    it "broadcast_append renders content and forwards append action" do
      allow(todo).to receive(:render_broadcast_content).and_return("<li>Updated Todo</li>")

      todo.broadcast_append("#todos")

      expect(todo).to have_received(:render_broadcast_content).once
      expect(ActionCable.server).to have_received(:broadcast).with(
        "resource:todo:user:1",
        hash_including(
          action: "append",
          target: "#todos",
          content: "<li>Updated Todo</li>",
          id: "todo_#{todo.id}"
        )
      )
    end

    it "broadcast_remove keeps nil content" do
      expect(todo).not_to receive(:render_broadcast_content)

      todo.broadcast_remove("#todo_#{todo.id}")

      expect(ActionCable.server).to have_received(:broadcast).with(
        "resource:todo:user:1",
        hash_including(
          action: "remove",
          target: "#todo_#{todo.id}",
          content: nil,
          id: "todo_#{todo.id}"
        )
      )
    end
  end
end
