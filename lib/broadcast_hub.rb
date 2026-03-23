# frozen_string_literal: true

require "logger"
require "broadcast_hub/version"
require "broadcast_hub/configuration"
require "broadcast_hub/engine"

module BroadcastHub
  class << self
    attr_writer :configuration

    def configuration
      @configuration ||= Configuration.new
    end

    def configure
      yield(configuration)
    end
  end
end
