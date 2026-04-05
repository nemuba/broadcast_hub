# frozen_string_literal: true

require 'rails_helper'

RSpec.describe BroadcastHub::StreamChannel, type: :channel do
  let(:current_user) { instance_double('User', id: 11) }
  let(:configuration) do
    double(
      'configuration',
      allowed_resources: %w[todo order],
      authorize_scope: ->(context) { context.tenant_id == 't1' },
      stream_key_resolver: ->(context) { "tenant:#{context.tenant_id}:#{context.resource_name}:user:#{context.current_user&.id}" }
    )
  end

  before do
    allow(BroadcastHub).to receive(:configuration).and_return(configuration)
    stub_connection current_user: current_user
  end

  it 'keeps authorization/scope behavior unchanged for replace feature flows' do
    subscribe(resource: 'todo', tenant: 't1', action: 'replace')

    expect(subscription).to be_confirmed
    expect(subscription).to have_stream_from('tenant:t1:todo:user:11')
  end

  it 'still rejects invalid scope even when action hint is replace' do
    subscribe(resource: 'todo', tenant: 'other', action: 'replace')

    expect(subscription).to be_rejected
  end
end
