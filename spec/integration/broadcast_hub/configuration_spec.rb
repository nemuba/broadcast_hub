# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'BroadcastHub initializer configuration', type: :model do
  it 'sets the host app configuration contract' do
    configuration = BroadcastHub.configuration

    expect(configuration.allowed_resources).to include('todo')
    expect(configuration.authorize_scope).to respond_to(:call)
    expect(configuration.stream_key_resolver).to respond_to(:call)

    user = instance_double('User', id: 7)
    user_context = instance_double(
      'BroadcastHub::Context',
      resource_name: 'todo',
      current_user: user
    )
    anonymous_context = instance_double(
      'BroadcastHub::Context',
      resource_name: 'todo',
      current_user: nil
    )

    expect(configuration.stream_key_resolver.call(user_context)).to eq('resource:todo:user:7')
    expect(configuration.stream_key_resolver.call(anonymous_context)).to eq('resource:todo')
  end
end
