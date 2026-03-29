# frozen_string_literal: true

module BroadcastHub
  class Engine < ::Rails::Engine
    isolate_namespace BroadcastHub

    initializer "broadcast_hub.controller_helpers" do
      ActiveSupport.on_load(:action_controller_base) do
        include BroadcastHub::ControllerHelpers
      end
    end

    initializer "broadcast_hub.dom_id_helper" do
      ActiveSupport.on_load(:action_controller_base) do
        include BroadcastHub::DomIdHelper
      end

      ActiveSupport.on_load(:action_view) do
        include BroadcastHub::DomIdHelper
      end
    end
  end
end
