# frozen_string_literal: true

module BroadcastHub
  # Builds and validates normalized payloads sent through Action Cable.
  class PayloadBuilder
    # Raised when payload data is invalid.
    class ValidationError < StandardError; end

    VALID_ACTIONS = %w[append prepend update remove dispatch].freeze
    ACTIONS_REQUIRING_CONTENT = %w[append prepend update].freeze
    ALLOWED_KEYS = %i[version action target content id meta event_name event_data].freeze

    class << self
      # Builds the broadcast payload hash.
      #
      # @param action [String] one of {VALID_ACTIONS}
      # @param target [String] DOM target identifier
      # @param content [String, nil] rendered HTML for non-remove actions
      # @param id [String] unique entry identifier
      # @param meta [Hash, nil] optional metadata included in the payload
      # @param event_name [String, nil] for dispatch action
      # @param event_data [Hash, nil] for dispatch action
      # @return [Hash] payload constrained to {ALLOWED_KEYS}
      # @raise [ValidationError] when any input fails validation
      def build(action:, target:, content:, id:, meta: {}, event_name: nil, event_data: {})
        validate_action!(action)
        validate_target!(target)
        validate_id!(id)
        validate_content!(action, content)
        validate_dispatch!(action, event_name, event_data)

        payload = {
          version: BroadcastHub.configuration.payload_version,
          action: action,
          target: target,
          content: content,
          id: id,
          meta: normalize_meta(meta)
        }

        if action == "dispatch"
          payload[:event_name] = event_name
          payload[:event_data] = event_data
        end

        payload.slice(*ALLOWED_KEYS)
      end

      private

      # @param action [String]
      # @param event_name [String, nil]
      # @param event_data [Hash, nil]
      # @raise [ValidationError]
      def validate_dispatch!(action, event_name, event_data)
        return unless action == "dispatch"

        raise ValidationError, "event_name required for dispatch" if event_name.to_s.strip.empty?
        raise ValidationError, "event_data must be a hash for dispatch" unless event_data.is_a?(Hash)
      end

      # @param action [String]
      # @raise [ValidationError]
      def validate_action!(action)
        raise ValidationError, "invalid action" unless VALID_ACTIONS.include?(action)
      end

      # @param target [String]
      # @raise [ValidationError]
      def validate_target!(target)
        raise ValidationError, "target required" if target.to_s.strip.empty?
      end

      # @param id [String]
      # @raise [ValidationError]
      def validate_id!(id)
        raise ValidationError, "id required" if id.to_s.strip.empty?
      end

      # @param action [String]
      # @param content [String, nil]
      # @raise [ValidationError]
      def validate_content!(action, content)
        return unless ACTIONS_REQUIRING_CONTENT.include?(action)
        raise ValidationError, "content required" if content.to_s.strip.empty?
      end

      # @param meta [Hash, nil]
      # @return [Hash]
      # @raise [ValidationError]
      def normalize_meta(meta)
        return {} if meta.nil?
        raise ValidationError, "meta must be a hash" unless meta.is_a?(Hash)

        meta
      end
    end
  end
end
