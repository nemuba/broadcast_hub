# frozen_string_literal: true

require_relative 'lib/broadcast_hub/version'

Gem::Specification.new do |spec|
  spec.name = 'broadcast_hub'
  spec.version = BroadcastHub::VERSION
  spec.summary = 'Reusable Action Cable broadcasting engine for Rails 5/6'
  spec.authors = [ 'BroadcastHub Team' ]
  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    Dir['{app,config,lib,vendor}/**/*', 'MIT-LICENSE', 'Rakefile', 'README.md']
  end
  spec.add_dependency 'jquery-rails'
  spec.add_dependency 'rails', '>= 5.2', '< 7.0'
  spec.metadata['rubygems_mfa_required'] = 'true'
end
