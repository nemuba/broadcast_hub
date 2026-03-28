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
    let(:broadcast_calls) { [] }

    before do
      BroadcastHub.configure do |config|
        config.allowed_resources = [ "todo" ]
        config.authorize_scope = ->(_context) { true }
        config.stream_key_resolver = ->(_context) { "resource:todo:user:1" }
      end

      allow(ActionCable.server).to receive(:broadcast) do |stream_key, payload|
        broadcast_calls << [ stream_key, payload ]
      end
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

    describe "broadcast_dispatch validation" do
      it "raises for blank event_name" do
        expect {
          todo.broadcast_dispatch("#todos", " ", { todo_id: todo.id })
        }.to raise_error(BroadcastHub::PayloadBuilder::ValidationError, "event_name required for dispatch")
      end

      it "raises for non-hash event_data" do
        expect {
          todo.broadcast_dispatch("#todos", "todo:highlight", "invalid")
        }.to raise_error(BroadcastHub::PayloadBuilder::ValidationError, "event_data must be a hash for dispatch")
      end
    end

    shared_examples "non-dispatch content action" do |method_name, payload_action|
      it "#{method_name} renders content and omits dispatch-only keys" do
        rendered_content = "<li>Updated Todo</li>"

        allow(todo).to receive(:render_broadcast_content).and_return(rendered_content)

        todo.public_send(method_name, "#todos")

        expect(todo).to have_received(:render_broadcast_content).once
        stream_key, payload = broadcast_calls.last

        expect(stream_key).to eq("resource:todo:user:1")
        expect(payload).to include(
          action: payload_action,
          target: "#todos",
          content: rendered_content,
          id: "todo_#{todo.id}"
        )
        expect(payload).not_to include(:event_name, :event_data)
      end
    end

    include_examples "non-dispatch content action", :broadcast_append, "append"
    include_examples "non-dispatch content action", :broadcast_prepend, "prepend"
    include_examples "non-dispatch content action", :broadcast_update, "update"

    it "broadcast_remove keeps nil content" do
      expect(todo).not_to receive(:render_broadcast_content)

      todo.broadcast_remove("#todo_#{todo.id}")

      stream_key, payload = broadcast_calls.last

      expect(stream_key).to eq("resource:todo:user:1")
      expect(payload).to include(
        action: "remove",
        target: "#todo_#{todo.id}",
        content: nil,
        id: "todo_#{todo.id}"
      )
      expect(payload).not_to include(:event_name, :event_data)
    end
  end
end
