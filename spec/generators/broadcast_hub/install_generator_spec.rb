# frozen_string_literal: true

require 'rails_helper'
require BroadcastHub::Engine.root.join('lib/generators/broadcast_hub/install_generator').to_s

RSpec.describe BroadcastHub::Generators::InstallGenerator do
  let(:destination_root) { BroadcastHub::Engine.root.join('tmp/generator_specs/broadcast_hub_install').to_s }
  let(:initializer_path) { File.join(destination_root, 'config/initializers/broadcast_hub.rb') }
  let(:application_js_path) { File.join(destination_root, 'app/assets/javascripts/application.js') }

  before do
    FileUtils.rm_rf(destination_root)
    FileUtils.mkdir_p(destination_root)
    FileUtils.mkdir_p(File.dirname(application_js_path))
    File.write(application_js_path, "//= require rails-ujs\n")
  end

  after do
    FileUtils.rm_rf(destination_root)
  end

  it 'generates initializer with resolver, authorization, and resource scaffolding' do
    expect do
      Rails::Generators.invoke(
        'broadcast_hub:install',
        [],
        destination_root: destination_root
      )
    end.to output(%r{app/assets/javascripts/application\.js.*//= require broadcast_hub/index}m).to_stdout

    expect(File).to exist(initializer_path)

    content = File.read(initializer_path)

    expect(content).to include('config.allowed_resources')
    expect(content).to include('config.authorize_scope')
    expect(content).to include('config.stream_key_resolver')
    expect(content).to include('"resource:#{context.resource_name}"')
    expect(content).to include('Auth mode example')
    expect(content).to include('No-auth mode example')
    expect(content).to include('current_user')
    expect(content).to include('session_id')
    expect(content).to include('ApplicationCable::Connection')

    application_js_content = File.read(application_js_path)

    expect(application_js_content).to include('//= require jquery3')
    expect(application_js_content).to include('//= require broadcast_hub/index')
  end
end
