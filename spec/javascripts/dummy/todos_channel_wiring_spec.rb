# frozen_string_literal: true

require 'rails_helper'
require 'execjs'

RSpec.describe 'Dummy todos channel wiring' do
  let(:todos_channel_source) do
    File.read(BroadcastHub::Engine.root.join('spec/dummy/app/assets/javascripts/channels/todos_channel.js'))
  end

  let(:cable_source) do
    File.read(BroadcastHub::Engine.root.join('spec/dummy/app/assets/javascripts/cable.js'))
  end

  let(:runtime) do
    ExecJS.compile(
      <<~JS
        var document = {};
        var wireCalls = 0;

        function BroadcastHubJQueryController($) {
          this.$ = $;
        }

        BroadcastHubJQueryController.prototype.apply = function() {};

        function BroadcastHubSubscription(consumer, controller) {
          this.consumer = consumer;
          this.controller = controller;
        }

        BroadcastHubSubscription.prototype.subscribe = function(resourceName) {
          wireCalls += 1;
          return { resourceName: resourceName, consumer: this.consumer };
        };

        function buildJQueryStub() {
          function JQueryCollection(selector) {
            this.selector = selector;
            this.length = 1;
          }

          JQueryCollection.prototype.off = function() { return this; };
          JQueryCollection.prototype.on = function() { return this; };

          function $(selector) {
            return new JQueryCollection(selector);
          }

          return $;
        }

        var jQuery = buildJQueryStub();
        this.jQuery = jQuery;

        var ActionCable = {
          createConsumer: function() {
            return { id: 'consumer' };
          }
        };
        this.ActionCable = ActionCable;

        #{todos_channel_source}
        #{cable_source}

        function wiringState() {
          return {
            wired: !!(this.App && this.App.todo_channel),
            wireCalls: wireCalls
          };
        }
      JS
    )
  end

  it 'wires TodoChannel after cable consumer initialization' do
    state = runtime.eval('wiringState()')

    expect(state).to eq(
      {
        'wired' => true,
        'wireCalls' => 1
      }
    )
  end
end
