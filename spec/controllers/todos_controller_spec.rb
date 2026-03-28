# frozen_string_literal: true

require 'rails_helper'

RSpec.describe TodosController, type: :controller do
  describe 'POST #highlight' do
    it 'dispatches highlight event to the todo row dom id' do
      user = create(:user)
      todo = create(:todo, user_id: user.id)

      allow(controller).to receive(:authenticate_user!).and_return(true)
      allow(controller).to receive(:current_user).and_return(user)
      expected_target = "##{ActionView::RecordIdentifier.dom_id(todo)}"

      expect_any_instance_of(Todo).to receive(:broadcast_dispatch).with(
        expected_target,
        'todo:highlight',
        { id: todo.id, title: todo.title }
      )

      post :highlight, params: { id: todo.id }, format: :js
    end
  end

  describe 'GET #datatable' do
    render_views

    it 'renders destacar action as a post form button' do
      user = create(:user)
      todo = create(:todo, user_id: user.id)

      allow(controller).to receive(:authenticate_user!).and_return(true)
      allow(controller).to receive(:current_user).and_return(user)

      get :datatable

      html = Nokogiri::HTML(response.body)
      form = html.at_css("form[action='#{highlight_todo_path(todo, format: :js)}']")

      expect(form).not_to be_nil
      expect(form['method']).to eq('post')
      expect(form.at_css("button[type='submit']")&.text.to_s).to include('Destacar')
    end
  end
end
