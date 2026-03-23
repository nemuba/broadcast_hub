# frozen_string_literal: true

module BroadcastHub
  # Renders partials used in broadcast payloads.
  class Renderer
    # @param renderer [#render] rendering backend, defaults to Rails renderer
    def initialize(renderer: ApplicationController.renderer)
      @renderer = renderer
    end

    # Renders a partial with locals.
    #
    # @param partial [String] partial path
    # @param locals [Hash] locals passed to the partial
    # @return [String] rendered HTML fragment
    def render(partial:, locals: {})
      @renderer.render(partial: partial, locals: locals)
    end
  end
end
