# frozen_string_literal: true

require "rails/generators"

module BroadcastHub
  module Generators
    class InstallGenerator < Rails::Generators::Base
      source_root File.expand_path("templates", __dir__)

      def copy_initializer
        template "broadcast_hub.rb.tt", "config/initializers/broadcast_hub.rb"
      end

      def add_javascript_requires
        manifest_path = "app/assets/javascripts/application.js"
        absolute_manifest_path = File.expand_path(manifest_path, destination_root)

        unless File.exist?(absolute_manifest_path)
          say_status :skip, "#{manifest_path} not found", :yellow
          return
        end

        directives = [
          "//= require jquery3",
          "//= require broadcast_hub/index"
        ]

        manifest_content = File.read(absolute_manifest_path)
        missing_directives = directives.reject { |directive| manifest_content.include?(directive) }
        return if missing_directives.empty?

        append_to_file manifest_path, "\n#{missing_directives.join("\n")}\n"
      end

      def show_javascript_install_hint
        say "Add BroadcastHub assets in app/assets/javascripts/application.js:"
        say "//= require jquery3"
        say "//= require broadcast_hub/index"
      end
    end
  end
end
