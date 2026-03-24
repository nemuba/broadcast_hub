# frozen_string_literal: true

require 'factory_bot'

RSpec.configure do |config|
  config.include FactoryBot::Syntax::Methods
  config.before(:suite) do
    FactoryBot.definition_file_paths << File.expand_path("#{BroadcastHub::Engine.root}/spec/factories", __dir__)
    FactoryBot.find_definitions
  end
end
