# frozen_string_literal: true

require 'rails_helper'
require 'execjs'

RSpec.describe 'BroadcastHubJQueryController runtime actions' do
  let(:controller_source) do
    File.read(BroadcastHub::Engine.root.join('app/javascripts/broadcast_hub/jquery_controller.js')).sub('export default ', '')
  end

  let(:runtime) do
    ExecJS.compile(
      <<~JS
        #{controller_source}

        function buildJQueryStub() {
          var dispatchedEvents = [];
          var replacedElements = [];

          function JQueryCollection(selector) {
            this.selector = selector;
            this.length = selector && selector !== '#missing' ? 1 : 0;
          }

          JQueryCollection.prototype.trigger = function(eventName, args) {
            dispatchedEvents.push({
              selector: this.selector,
              eventName: eventName,
              args: args
            });

            return this;
          };

          JQueryCollection.prototype.replaceWith = function(content) {
            if (this.length > 0) {
              replacedElements.push({
                selector: this.selector,
                content: content
              });
            }

            return this;
          };

          function $(selector) {
            return new JQueryCollection(selector);
          }

          $.dispatchedEvents = dispatchedEvents;
          $.replacedElements = replacedElements;
          return $;
        }

        function runController(payload) {
          var $ = buildJQueryStub();
          var controller = new BroadcastHubJQueryController($);
          controller.apply(payload);
          return {
            dispatchedEvents: $.dispatchedEvents,
            replacedElements: $.replacedElements
          };
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

    result = runtime.eval("runController(#{payload.to_json})")

    expect(result['dispatchedEvents']).to eq(
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
    expect(result['replacedElements']).to eq([])
  end

  it 'ignores dispatch payloads with blank event_name' do
    payload = {
      action: 'dispatch',
      target: '#todos',
      content: nil,
      event_name: '   ',
      event_data: { todo_id: 42 }
    }

    result = runtime.eval("runController(#{payload.to_json})")

    expect(result['dispatchedEvents']).to eq([])
    expect(result['replacedElements']).to eq([])
  end

  it 'replaces target element content when action is replace' do
    payload = {
      action: 'replace',
      target: '#todo_42',
      content: '<li id="todo_42">Updated</li>',
      id: 'todo_42'
    }

    result = runtime.eval("runController(#{payload.to_json})")

    expect(result['dispatchedEvents']).to eq([])
    expect(result['replacedElements']).to eq(
      [
        {
          'selector' => '#todo_42',
          'content' => '<li id="todo_42">Updated</li>'
        }
      ]
    )
  end

  it 'keeps replace as safe no-op when target is missing' do
    payload = {
      action: 'replace',
      target: '#missing',
      content: '<li id="todo_99">Updated</li>',
      id: 'todo_99'
    }

    result = runtime.eval("runController(#{payload.to_json})")

    expect(result['dispatchedEvents']).to eq([])
    expect(result['replacedElements']).to eq([])
  end

  it 'applies replace safely when id does not match target' do
    payload = {
      action: 'replace',
      target: '#todo_42',
      content: '<li id="todo_42">Updated</li>',
      id: 'todo_999'
    }

    result = runtime.eval("runController(#{payload.to_json})")

    expect(result['dispatchedEvents']).to eq([])
    expect(result['replacedElements']).to eq(
      [
        {
          'selector' => '#todo_42',
          'content' => '<li id="todo_42">Updated</li>'
        }
      ]
    )
  end

  it 'ignores replace payloads with blank content' do
    payload = {
      action: 'replace',
      target: '#todo_42',
      content: ' ',
      id: 'todo_42'
    }

    result = runtime.eval("runController(#{payload.to_json})")

    expect(result['dispatchedEvents']).to eq([])
    expect(result['replacedElements']).to eq([])
  end
end
