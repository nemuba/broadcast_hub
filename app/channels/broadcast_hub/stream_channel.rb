# frozen_string_literal: true

module BroadcastHub
  # Action Cable channel that subscribes clients to authorized BroadcastHub streams.
  class StreamChannel < ApplicationCable::Channel
    # Starts stream subscription for the current channel connection.
    #
    # @return [void]
    def subscribed
      stream_from(BroadcastHub::StreamKeyResolver.resolve!(stream_key_context))
    rescue BroadcastHub::StreamKeyResolver::Unauthorized => e
      logger.info("broadcast_hub.reject reason=#{e.message}") if defined?(Rails) && Rails.env.development?
      reject
    end

    private

    # Builds the stream key context from connection data and params.
    #
    # @return [BroadcastHub::StreamKeyContext]
    def stream_key_context
      BroadcastHub::StreamKeyContext.from_connection(connection: connection, params: params)
    end
  end
end
