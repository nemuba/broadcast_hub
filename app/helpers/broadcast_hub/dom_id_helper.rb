# frozen_string_literal: true

module BroadcastHub
  module DomIdHelper
    def dom_id(record, positional_prefix = nil, prefix: nil, suffix: nil)
      normalized_prefix = normalize_token(prefix)

      if !positional_prefix.nil? && !normalized_prefix.nil?
        raise ArgumentError, "provide positional prefix or keyword prefix, not both"
      end

      effective_prefix = positional_prefix || normalized_prefix
      normalized_suffix = normalize_token(suffix)
      base = ActionView::RecordIdentifier.dom_id(record, effective_prefix)

      [ base, normalized_suffix ].compact.join("_")
    end

    private

    def normalize_token(value)
      normalized = value.to_s.strip
      normalized.empty? ? nil : normalized
    end
  end
end
