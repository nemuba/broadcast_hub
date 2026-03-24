# frozen_string_literal: true

require 'rails_helper'

RSpec.describe BroadcastHub::StreamChannel, type: :channel do
  let(:current_user) { create(:user) }

  before do
    stub_connection current_user: current_user
  end

  it 'subscribes todo resource to authenticated user stream' do
    subscribe(resource: 'todo')

    expect(subscription).to be_confirmed
    expect(subscription).to have_stream_from("resource:todo:user:#{current_user.id}")
  end
end
