# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'BroadcastHub dom_id helper', type: :helper do
  let(:user) { create(:user) }
  let(:todo) { create(:todo, id: 42, user_id: user.id) }

  describe '#dom_id' do
    it 'returns the default dom id for a record' do
      expect(helper.dom_id(todo)).to eq('todo_42')
    end

    it 'supports Rails positional prefix compatibility' do
      expect(helper.dom_id(todo, :edit)).to eq('edit_todo_42')
    end

    it 'supports keyword prefix wrapper' do
      expect(helper.dom_id(todo, prefix: 'row')).to eq('row_todo_42')
    end

    it 'supports keyword suffix wrapper' do
      expect(helper.dom_id(todo, suffix: 'highlight')).to eq('todo_42_highlight')
    end

    it 'supports keyword prefix and suffix wrappers together' do
      expect(helper.dom_id(todo, prefix: 'row', suffix: 'highlight')).to eq('row_todo_42_highlight')
    end

    it 'ignores blank keyword prefix' do
      expect(helper.dom_id(todo, prefix: '   ')).to eq('todo_42')
    end

    it 'ignores blank keyword suffix' do
      expect(helper.dom_id(todo, suffix: '   ')).to eq('todo_42')
    end

    it 'coerces symbol prefix and suffix to strings' do
      expect(helper.dom_id(todo, prefix: :row, suffix: :highlight)).to eq('row_todo_42_highlight')
    end

    it 'trims keyword prefix and suffix values' do
      expect(helper.dom_id(todo, prefix: ' row ', suffix: ' highlight ')).to eq('row_todo_42_highlight')
    end

    it 'raises when positional prefix and keyword prefix are both provided' do
      expect do
        helper.dom_id(todo, :edit, prefix: 'row')
      end.to raise_error(ArgumentError, 'provide positional prefix or keyword prefix, not both')
    end

    it 'ignores blank keyword prefix when positional prefix is provided' do
      expect(helper.dom_id(todo, :edit, prefix: '   ')).to eq('edit_todo_42')
    end
  end
end
