# frozen_string_literal: true

module BroadcastHub
  # Immutable context object shared by stream key authorization and resolution.
  class StreamKeyContext
    attr_reader :resource_name, :tenant_id, :current_user, :session_id, :params

    # Builds a context from an Action Cable connection and channel params.
    #
    # @param connection [Object] Action Cable connection
    # @param params [#to_h, #to_unsafe_h] channel subscription params
    # @return [BroadcastHub::StreamKeyContext]
    def self.from_connection(connection:, params: {})
      normalized_params = normalize_params(params)

      new(
        resource_name: normalized_params[:resource],
        tenant_id: normalized_params[:tenant],
        current_user: connection_value(connection, :current_user),
        session_id: connection_value(connection, :session_id) || normalized_params[:session_id],
        params: normalized_params
      )
    end

    # @param resource_name [String, Symbol, nil] resource requested by the client
    # @param tenant_id [Object] tenant identity for scoped streams
    # @param current_user [Object] authenticated user on the connection
    # @param session_id [String, nil] optional session identifier
    # @param params [Hash] normalized channel params
    def initialize(resource_name:, tenant_id:, current_user:, session_id:, params: {})
      @resource_name = resource_name
      @tenant_id = tenant_id
      @current_user = current_user
      @session_id = session_id
      @params = (params || {}).dup.freeze
      freeze
    end

    class << self
      private

      # @param params [#to_h, #to_unsafe_h]
      # @return [Hash] params normalized to symbol keys
      def normalize_params(params)
        hash = params.respond_to?(:to_unsafe_h) ? params.to_unsafe_h : params.to_h
        hash.symbolize_keys
      rescue StandardError
        {}
      end

      # @param connection [Object]
      # @param key [Symbol]
      # @return [Object, nil]
      def connection_value(connection, key)
        return nil unless connection.respond_to?(key)

        connection.public_send(key)
      end
    end
  end
end
