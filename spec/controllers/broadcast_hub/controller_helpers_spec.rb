# frozen_string_literal: true

require 'rails_helper'

RSpec.describe BroadcastHub::ControllerHelpers, type: :controller do
  controller(ActionController::Base) do
    include BroadcastHub::ControllerHelpers

    def create
      render_broadcast(
        action: 'append',
        target: '#todos',
        resource: 'todo',
        partial: 'todos/partials/todo',
        locals: { title: 'Task' }
      )
    end

    def create_with_id
      render_broadcast(
        action: 'append',
        target: '#todos',
        resource: 'todo',
        partial: 'todos/partials/todo',
        locals: { title: 'Task' },
        id: 'todo-42'
      )
    end

    def invalid_create
      render_broadcast(
        action: 'append',
        target: '#todos',
        resource: nil,
        partial: 'todos/partials/todo'
      )
    end

    def remove_item
      render_broadcast(
        action: 'remove',
        target: '#todo_1',
        resource: 'todo',
        partial: 'todos/partials/todo'
      )
    end

    def append_without_partial
      render_broadcast(
        action: 'append',
        target: '#todos',
        resource: 'todo'
      )
    end

    def dispatch_blank_event_name
      render_broadcast(
        action: 'dispatch',
        target: '#todo_1',
        resource: 'todo',
        event_name: ' '
      )
    end

    def invalid_action
      render_broadcast(
        action: 'invalid',
        target: '#todos',
        resource: 'todo',
        partial: 'todos/partials/todo'
      )
    end

    def unauthorized_create
      render_broadcast(
        action: 'append',
        target: '#todos',
        resource: 'todo',
        partial: 'todos/partials/todo'
      )
    end
  end

  before do
    routes.draw do
      post 'create' => 'anonymous#create'
      post 'create_with_id' => 'anonymous#create_with_id'
      post 'invalid_create' => 'anonymous#invalid_create'
      post 'remove_item' => 'anonymous#remove_item'
      post 'append_without_partial' => 'anonymous#append_without_partial'
      post 'dispatch_blank_event_name' => 'anonymous#dispatch_blank_event_name'
      post 'invalid_action' => 'anonymous#invalid_action'
      post 'unauthorized_create' => 'anonymous#unauthorized_create'
    end
  end

  it 'renders content, resolves stream key, broadcasts payload, and returns head :ok' do
    rendered_content = '<li>Task</li>'
    stream_key = 'resource:todo:user:1'
    payload = { action: 'append', target: '#todos', content: rendered_content, id: 'uuid-123', meta: {} }
    context = instance_double(BroadcastHub::StreamKeyContext)
    renderer = instance_double(BroadcastHub::Renderer)

    allow(SecureRandom).to receive(:uuid).and_return('uuid-123')
    expect(BroadcastHub::Renderer).to receive(:new).with(renderer: controller).and_return(renderer)
    expect(renderer).to receive(:render).with(partial: 'todos/partials/todo', locals: { title: 'Task' }).and_return(rendered_content)
    expect(BroadcastHub::StreamKeyContext).to receive(:new).with(
      hash_including(
        resource_name: 'todo',
        tenant_id: nil,
        current_user: nil,
        params: hash_including('action' => 'create')
      )
    ).and_return(context)
    expect(BroadcastHub::StreamKeyResolver).to receive(:resolve!).with(context).and_return(stream_key)
    expect(BroadcastHub::PayloadBuilder).to receive(:build).with(
      action: 'append',
      target: '#todos',
      content: rendered_content,
      id: 'uuid-123',
      meta: {},
      event_name: nil,
      event_data: {}
    ).and_return(payload)
    expect(ActionCable.server).to receive(:broadcast).with(stream_key, payload)

    post :create

    expect(response).to have_http_status(:ok)
    expect(response.body).to be_empty
  end

  it 'raises ArgumentError when resource is missing' do
    expect do
      post :invalid_create
    end.to raise_error(ArgumentError, 'resource required')
  end

  it 'forces content nil for remove and does not render partial' do
    stream_key = 'resource:todo:user:1'
    payload = { action: 'remove', target: '#todo_1', content: nil, id: 'uuid-remove', meta: {} }
    context = instance_double(BroadcastHub::StreamKeyContext)

    allow(SecureRandom).to receive(:uuid).and_return('uuid-remove')
    expect(BroadcastHub::Renderer).not_to receive(:new)
    expect(BroadcastHub::StreamKeyContext).to receive(:new).with(
      hash_including(
        resource_name: 'todo',
        tenant_id: nil,
        current_user: nil,
        params: hash_including('action' => 'remove_item')
      )
    ).and_return(context)
    expect(BroadcastHub::StreamKeyResolver).to receive(:resolve!).with(context).and_return(stream_key)
    expect(BroadcastHub::PayloadBuilder).to receive(:build).with(
      action: 'remove',
      target: '#todo_1',
      content: nil,
      id: 'uuid-remove',
      meta: {},
      event_name: nil,
      event_data: {}
    ).and_return(payload)
    expect(ActionCable.server).to receive(:broadcast).with(stream_key, payload)

    post :remove_item

    expect(response).to have_http_status(:ok)
    expect(response.body).to be_empty
  end

  it 'raises ArgumentError when partial is missing for append' do
    expect do
      post :append_without_partial
    end.to raise_error(ArgumentError, 'partial required for append')
  end

  it 'uses provided id and does not generate a UUID' do
    rendered_content = '<li>Task</li>'
    stream_key = 'resource:todo:user:1'
    payload = { action: 'append', target: '#todos', content: rendered_content, id: 'todo-42', meta: {} }
    context = instance_double(BroadcastHub::StreamKeyContext)
    renderer = instance_double(BroadcastHub::Renderer)

    expect(SecureRandom).not_to receive(:uuid)
    expect(BroadcastHub::Renderer).to receive(:new).with(renderer: controller).and_return(renderer)
    expect(renderer).to receive(:render).with(partial: 'todos/partials/todo', locals: { title: 'Task' }).and_return(rendered_content)
    allow(BroadcastHub::StreamKeyContext).to receive(:new).and_return(context)
    allow(BroadcastHub::StreamKeyResolver).to receive(:resolve!).with(context).and_return(stream_key)
    expect(BroadcastHub::PayloadBuilder).to receive(:build).with(
      action: 'append',
      target: '#todos',
      content: rendered_content,
      id: 'todo-42',
      meta: {},
      event_name: nil,
      event_data: {}
    ).and_return(payload)
    expect(ActionCable.server).to receive(:broadcast).with(stream_key, payload)

    post :create_with_id

    expect(response).to have_http_status(:ok)
    expect(response.body).to be_empty
  end

  it 'generates a UUID when id is omitted' do
    rendered_content = '<li>Task</li>'
    stream_key = 'resource:todo:user:1'
    payload = { action: 'append', target: '#todos', content: rendered_content, id: 'uuid-fallback', meta: {} }
    context = instance_double(BroadcastHub::StreamKeyContext)
    renderer = instance_double(BroadcastHub::Renderer)

    allow(SecureRandom).to receive(:uuid).and_return('uuid-fallback')
    expect(BroadcastHub::Renderer).to receive(:new).with(renderer: controller).and_return(renderer)
    expect(renderer).to receive(:render).with(partial: 'todos/partials/todo', locals: { title: 'Task' }).and_return(rendered_content)
    allow(BroadcastHub::StreamKeyContext).to receive(:new).and_return(context)
    allow(BroadcastHub::StreamKeyResolver).to receive(:resolve!).with(context).and_return(stream_key)
    expect(BroadcastHub::PayloadBuilder).to receive(:build).with(
      action: 'append',
      target: '#todos',
      content: rendered_content,
      id: 'uuid-fallback',
      meta: {},
      event_name: nil,
      event_data: {}
    ).and_return(payload)
    expect(ActionCable.server).to receive(:broadcast).with(stream_key, payload)

    post :create

    expect(response).to have_http_status(:ok)
    expect(response.body).to be_empty
  end

  it 'raises ValidationError when dispatch event_name is blank' do
    context = instance_double(BroadcastHub::StreamKeyContext)

    allow(SecureRandom).to receive(:uuid).and_return('uuid-dispatch')
    expect(BroadcastHub::Renderer).not_to receive(:new)
    allow(BroadcastHub::StreamKeyContext).to receive(:new).and_return(context)
    allow(BroadcastHub::StreamKeyResolver).to receive(:resolve!).with(context).and_return('resource:todo:user:1')
    expect(ActionCable.server).not_to receive(:broadcast)

    expect do
      post :dispatch_blank_event_name
    end.to raise_error(BroadcastHub::PayloadBuilder::ValidationError, 'event_name required for dispatch')
  end

  it 'propagates StreamKeyResolver::Unauthorized' do
    rendered_content = '<li>Task</li>'
    context = instance_double(BroadcastHub::StreamKeyContext)
    renderer = instance_double(BroadcastHub::Renderer)

    allow(SecureRandom).to receive(:uuid).and_return('uuid-unauthorized')
    expect(BroadcastHub::Renderer).to receive(:new).with(renderer: controller).and_return(renderer)
    expect(renderer).to receive(:render).with(partial: 'todos/partials/todo', locals: {}).and_return(rendered_content)
    allow(BroadcastHub::StreamKeyContext).to receive(:new).and_return(context)
    expect(BroadcastHub::StreamKeyResolver).to receive(:resolve!).with(context).and_raise(BroadcastHub::StreamKeyResolver::Unauthorized, 'unauthorized_scope')
    expect(BroadcastHub::PayloadBuilder).not_to receive(:build)
    expect(ActionCable.server).not_to receive(:broadcast)

    expect do
      post :unauthorized_create
    end.to raise_error(BroadcastHub::StreamKeyResolver::Unauthorized, 'unauthorized_scope')
  end

  it 'uses the configured payload version in broadcast payload' do
    rendered_content = '<li>Task</li>'
    context = instance_double(BroadcastHub::StreamKeyContext)
    renderer = instance_double(BroadcastHub::Renderer)
    original_version = BroadcastHub.configuration.payload_version

    BroadcastHub.configuration.payload_version = 77

    allow(SecureRandom).to receive(:uuid).and_return('uuid-version')
    expect(BroadcastHub::Renderer).to receive(:new).with(renderer: controller).and_return(renderer)
    expect(renderer).to receive(:render).with(partial: 'todos/partials/todo', locals: { title: 'Task' }).and_return(rendered_content)
    allow(BroadcastHub::StreamKeyContext).to receive(:new).and_return(context)
    allow(BroadcastHub::StreamKeyResolver).to receive(:resolve!).with(context).and_return('resource:todo:user:1')
    expect(ActionCable.server).to receive(:broadcast).with(
      'resource:todo:user:1',
      hash_including(
        version: 77,
        action: 'append',
        target: '#todos',
        content: rendered_content,
        id: 'uuid-version'
      )
    )

    post :create

    expect(response).to have_http_status(:ok)
    expect(response.body).to be_empty
  ensure
    BroadcastHub.configuration.payload_version = original_version
  end

  it 'raises ValidationError for invalid action before rendering content' do
    expect(BroadcastHub::Renderer).not_to receive(:new)
    expect(BroadcastHub::StreamKeyContext).not_to receive(:new)
    expect(BroadcastHub::StreamKeyResolver).not_to receive(:resolve!)
    expect(ActionCable.server).not_to receive(:broadcast)

    expect do
      post :invalid_action
    end.to raise_error(BroadcastHub::PayloadBuilder::ValidationError, 'invalid action')
  end
end
