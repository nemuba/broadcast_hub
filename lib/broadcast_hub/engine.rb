# frozen_string_literal: true

module BroadcastHub
  class Engine < ::Rails::Engine
    isolate_namespace BroadcastHub

    initializer "broadcast_hub.controller_helpers" do
      ActiveSupport.on_load(:action_controller_base) do
        include BroadcastHub::ControllerHelpers
      end
    end
  end
end
