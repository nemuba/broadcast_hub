# frozen_string_literal: true

require 'rails_helper'
require 'execjs'

RSpec.describe 'BroadcastHubJQueryController dispatch action' do
  let(:controller_source) do
    File.read(BroadcastHub::Engine.root.join('app/javascripts/broadcast_hub/jquery_controller.js')).sub('export default ', '')
  end

  let(:runtime) do
    ExecJS.compile(
      <<~JS
        #{controller_source}

        function buildJQueryStub() {
          var dispatchedEvents = [];

          function JQueryCollection(selector) {
            this.selector = selector;
            this.length = selector ? 1 : 0;
          }

          JQueryCollection.prototype.trigger = function(eventName, args) {
            dispatchedEvents.push({
              selector: this.selector,
              eventName: eventName,
              args: args
            });

            return this;
          };

          function $(selector) {
            return new JQueryCollection(selector);
          }

          $.dispatchedEvents = dispatchedEvents;
          return $;
        }

        function runController(payload) {
          var $ = buildJQueryStub();
          var controller = new BroadcastHubJQueryController($);
          controller.apply(payload);
          return $.dispatchedEvents;
        }
      JS
    )
  end

  it 'triggers the dispatch event with event data' do
    payload = {
      action: 'dispatch',
      target: '#todos',
      content: nil,
      event_name: 'todo:highlight',
      event_data: { todo_id: 42, urgent: true }
    }

    dispatched_events = runtime.eval("runController(#{payload.to_json})")

    expect(dispatched_events).to eq(
      [
        {
          'selector' => '#todos',
          'eventName' => 'todo:highlight',
          'args' => [
            {
              'todo_id' => 42,
              'urgent' => true
            }
          ]
        }
      ]
    )
  end

  it 'ignores dispatch payloads with blank event_name' do
    payload = {
      action: 'dispatch',
      target: '#todos',
      content: nil,
      event_name: '   ',
      event_data: { todo_id: 42 }
    }

    dispatched_events = runtime.eval("runController(#{payload.to_json})")

    expect(dispatched_events).to eq([])
  end
end
