# frozen_string_literal: true

require_relative 'lib/broadcast_hub/version'

Gem::Specification.new do |spec|
  spec.name = 'broadcast_hub'
  spec.version = BroadcastHub::VERSION
  spec.summary = 'Reusable Action Cable broadcasting engine for Rails 5/6'
  spec.authors = [ 'Alef Oliveira' ]
  # URLs principais
  spec.homepage      = "https://github.com/nemuba/broadcast_hub"

  # Metadados adicionais (recomendado)
  spec.metadata = {
    "homepage_uri"      => "https://github.com/nemuba/broadcast_hub",
    "source_code_uri"   => "https://github.com/nemuba/broadcast_hub",
    "changelog_uri"     => "https://github.com/nemuba/broadcast_hub/blob/main/CHANGELOG.md",
    "bug_tracker_uri"   => "https://github.com/nemuba/broadcast_hub/issues"
  }

  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    Dir['{app,config,lib,vendor}/**/*', 'MIT-LICENSE', 'Rakefile', 'README.md']
  end

  spec.add_dependency 'jquery-rails'
  spec.add_dependency 'rails', '>= 5.2', '< 7.0'
  spec.metadata['rubygems_mfa_required'] = 'true'
end
