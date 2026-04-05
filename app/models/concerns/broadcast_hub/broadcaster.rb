# frozen_string_literal: true

module BroadcastHub
  # Adds lifecycle-driven Action Cable broadcasting helpers to models.
  module Broadcaster
    extend ActiveSupport::Concern

    # Broadcasts an append action for the model instance.
    #
    # @param target [String] DOM target for insertion
    # @return [void]
    def broadcast_append(target)
      broadcast_action("append", target)
    end

    # Broadcasts a prepend action for the model instance.
    #
    # @param target [String] DOM target for insertion
    # @return [void]
    def broadcast_prepend(target)
      broadcast_action("prepend", target)
    end

    # Broadcasts an update action for the model instance.
    #
    # @param target [String] DOM target to replace
    # @return [void]
    def broadcast_update(target)
      broadcast_action("update", target)
    end

    # Broadcasts a replace action for the model instance.
    #
    # @param target [String] DOM target to replace
    # @return [void]
    def broadcast_replace(target)
      broadcast_action("replace", target)
    end

    # Broadcasts a remove action for the model instance.
    #
    # @param target [String] DOM target to remove
    # @return [void]
    def broadcast_remove(target)
      broadcast_action("remove", target)
    end

    # Broadcasts a dispatch action for the model instance.
    #
    # @param target [String] DOM target for event dispatch
    # @param event_name [String] event name to dispatch
    # @param event_data [Hash] event payload data
    # @return [void]
    def broadcast_dispatch(target, event_name, event_data = {})
      broadcast_action("dispatch", target, event_name: event_name, event_data: event_data)
    end

    class_methods do
      # Configures callbacks and rendering metadata for model broadcasts.
      #
      # @param resource_name [String, Symbol] stream resource identifier
      # @param partial [String] partial used to render broadcast content
      # @param target [String] default DOM target used by lifecycle callbacks
      # @return [void]
      def broadcast_to(resource_name, partial:, target:)
        define_method(:broadcast_hub_resource_name) { resource_name.to_s }
        define_method(:broadcast_hub_partial) { partial }
        define_method(:broadcast_hub_target) { target }

        after_create_commit { broadcast_append(broadcast_hub_target) }
        after_update_commit { broadcast_update(broadcast_hub_target) }
        after_destroy_commit { broadcast_remove(broadcast_hub_target) }
      end
    end

    private

    # Broadcasts a payload to the configured stream key.
    #
    # @param action [String] payload action
    # @param target [String] DOM target
    # @param event_name [String, nil] event name for dispatch action
    # @param event_data [Hash] event payload data for dispatch action
    # @return [void]
    def broadcast_action(action, target, event_name: nil, event_data: {})
      content = %w[remove dispatch].include?(action) ? nil : render_broadcast_content
      payload = BroadcastHub::PayloadBuilder.build(
        action: action,
        target: target,
        content: content,
        id: broadcast_hub_dom_id,
        meta: {},
        event_name: event_name,
        event_data: event_data
      )

      ActionCable.server.broadcast(broadcast_hub_stream_key, payload)
    end

    # Renders model content used in append/prepend/update actions.
    #
    # @return [String]
    def render_broadcast_content
      BroadcastHub::Renderer.new.render(
        partial: broadcast_hub_partial,
        locals: { self.class.model_name.singular.to_sym => self }
      )
    end

    # Resolves the stream key for the current model event.
    #
    # @return [String]
    # @raise [RuntimeError] when stream key resolver is not configured
    def broadcast_hub_stream_key
      resolver = BroadcastHub.configuration.stream_key_resolver
      raise "stream_key_resolver not configured" unless resolver

      context_attributes = {
        tenant_id: nil,
        current_user: nil,
        session_id: nil,
        params: {}
      }.merge((broadcast_hub_stream_key_context_attributes || {}).to_h)

      resolver.call(
        BroadcastHub::StreamKeyContext.new(
          resource_name: broadcast_hub_resource_name,
          tenant_id: context_attributes[:tenant_id],
          current_user: context_attributes[:current_user],
          session_id: context_attributes[:session_id],
          params: context_attributes[:params]
        )
      )
    end

    # Default context attributes used for stream key resolution.
    #
    # @return [Hash]
    def broadcast_hub_stream_key_context_attributes
      {
        tenant_id: nil,
        current_user: nil,
        session_id: nil,
        params: {}
      }
    end

    # Generates a stable payload identifier for this instance.
    #
    # @return [String]
    def broadcast_hub_dom_id
      "#{self.class.model_name.singular}_#{id}"
    end
  end
end
