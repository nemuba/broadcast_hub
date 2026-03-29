# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'BroadcastHub::DomIdHelper exposure', type: :controller do
  controller(ActionController::Base) do
    def controller_context
      render plain: dom_id(Todo.new(id: 7), prefix: 'row', suffix: 'flash')
    end

    def in_view_context
      @todo = Todo.new(id: 7)
      render inline: "<%= dom_id(@todo, prefix: 'row', suffix: 'flash') %>"
    end
  end

  before do
    routes.draw do
      get 'controller_context' => 'anonymous#controller_context'
      get 'in_view_context' => 'anonymous#in_view_context'
    end
  end

  it 'exposes dom_id in controller context' do
    get :controller_context

    expect(response).to have_http_status(:ok)
    expect(response.body).to eq('row_todo_7_flash')
    expect(response.body).not_to eq('row_7')
  end

  it 'exposes dom_id in view context' do
    get :in_view_context

    expect(response).to have_http_status(:ok)
    expect(response.body).to eq('row_todo_7_flash')
    expect(response.body).not_to eq('row_7')
  end
end
