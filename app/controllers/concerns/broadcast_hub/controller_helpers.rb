# frozen_string_literal: true

require "securerandom"

module BroadcastHub
  module ControllerHelpers
    extend ActiveSupport::Concern

    ACTIONS_REQUIRING_CONTENT = %w[append prepend update].freeze
    ACTIONS_WITHOUT_CONTENT = %w[remove dispatch].freeze

    def render_broadcast(action:, target:, resource:, partial: nil, locals: {}, id: nil, meta: {}, event_name: nil, event_data: {}, status: :ok)
      raise ArgumentError, "resource required" if resource.to_s.strip.empty?

      normalized_action = normalize_action(action)
      validate_action!(normalized_action)
      resolved_id = id.presence || SecureRandom.uuid
      content = render_broadcast_content_for(action: normalized_action, partial: partial, locals: locals)
      context = build_stream_key_context(resource)
      stream_key = BroadcastHub::StreamKeyResolver.resolve!(context)

      payload = BroadcastHub::PayloadBuilder.build(
        action: normalized_action,
        target: target,
        content: content,
        id: resolved_id,
        meta: meta,
        event_name: event_name,
        event_data: event_data
      )

      ActionCable.server.broadcast(stream_key, payload)
      head status
    end

    private

    def normalize_action(action)
      action.to_s.strip
    end

    def validate_action!(action)
      return if BroadcastHub::PayloadBuilder::VALID_ACTIONS.include?(action)

      raise BroadcastHub::PayloadBuilder::ValidationError, "invalid action"
    end

    def render_broadcast_content_for(action:, partial:, locals:)
      return nil if ACTIONS_WITHOUT_CONTENT.include?(action)

      if ACTIONS_REQUIRING_CONTENT.include?(action) && partial.to_s.strip.empty?
        raise ArgumentError, "partial required for #{action}"
      end

      BroadcastHub::Renderer.new(renderer: self).render(partial: partial, locals: locals || {})
    end

    def build_stream_key_context(resource)
      BroadcastHub::StreamKeyContext.new(
        resource_name: resource,
        tenant_id: nil,
        current_user: resolved_current_user,
        session_id: request_session_id,
        params: request_params_hash
      )
    end

    def request_params_hash
      return params.to_unsafe_h if params.respond_to?(:to_unsafe_h)

      params.to_h
    rescue StandardError
      {}
    end

    def request_session_id
      request&.session&.id
    rescue StandardError
      nil
    end

    def resolved_current_user
      return nil unless respond_to?(:current_user, true)

      current_user
    rescue StandardError => e
      return nil if e.is_a?(NoMethodError)
      return nil if defined?(Devise::MissingWarden) && e.is_a?(Devise::MissingWarden)

      raise
    end
  end
end
