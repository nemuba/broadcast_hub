# frozen_string_literal: true

module BroadcastHub
  class Configuration
    attr_accessor :payload_version,
                  :update_strategy,
                  :strict_client_validation,
                  :allowed_resources,
                  :authorize_scope,
                  :stream_key_resolver

    def initialize
      @payload_version = 1
      @update_strategy = :replace_with
      @strict_client_validation = false
      @allowed_resources = []
      @authorize_scope = nil
      @stream_key_resolver = nil
    end
  end
end
