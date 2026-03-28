# frozen_string_literal: true

require 'rails_helper'

RSpec.describe TodosController, type: :controller do
  describe 'POST #highlight' do
    it 'dispatches highlight event to the todo row dom id' do
      user = create(:user)
      todo = create(:todo, user_id: user.id)

      allow(controller).to receive(:authenticate_user!).and_return(true)
      allow(controller).to receive(:current_user).and_return(user)
      allow(controller).to receive(:set_todo) { controller.instance_variable_set(:@todo, todo) }
      expect(todo).to receive(:broadcast_dispatch).with(
        "#todo_#{todo.id}",
        'todo:highlight',
        { id: todo.id, title: todo.title }
      )

      post :highlight, params: { id: todo.id }, format: :js
    end
  end
end
