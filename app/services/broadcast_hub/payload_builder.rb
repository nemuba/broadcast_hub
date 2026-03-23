# frozen_string_literal: true

module BroadcastHub
  # Builds and validates normalized payloads sent through Action Cable.
  class PayloadBuilder
    # Raised when payload data is invalid.
    class ValidationError < StandardError; end

    VALID_ACTIONS = %w[append prepend update remove].freeze
    ACTIONS_REQUIRING_CONTENT = %w[append prepend update].freeze
    ALLOWED_KEYS = %i[version action target content id meta].freeze

    class << self
      # Builds the broadcast payload hash.
      #
      # @param action [String] one of {VALID_ACTIONS}
      # @param target [String] DOM target identifier
      # @param content [String, nil] rendered HTML for non-remove actions
      # @param id [String] unique entry identifier
      # @param meta [Hash, nil] optional metadata included in the payload
      # @return [Hash] payload constrained to {ALLOWED_KEYS}
      # @raise [ValidationError] when any input fails validation
      def build(action:, target:, content:, id:, meta: {})
        validate_action!(action)
        validate_target!(target)
        validate_content!(action, content)

        payload = {
          version: BroadcastHub.configuration.payload_version,
          action: action,
          target: target,
          content: content,
          id: id,
          meta: normalize_meta(meta)
        }

        payload.slice(*ALLOWED_KEYS)
      end

      private

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
