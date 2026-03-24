# frozen_string_literal: true

# The TodosHelper module provides helper methods for working with todos.
module TodosHelper
  # Generates options for the todo status dropdown in a form.
  #
  # @param form [ActionView::Helpers::FormBuilder] The form builder object.
  # @return [String] The HTML options for the todo status dropdown.
  def options_for_todo_status(form)
    selected = form.object.new_record? ? nil : form.object.status
    options_for_select(Todo.statuses.map { |k, _| [ translate_enum(Todo, :status, k), k ] }, selected)
  end

  # Renders a partial for a todo.
  #
  # @param partial [String] The name of the partial to render.
  # @param locals [Hash] The locals to pass to the partial.
  # @param collection [Array] The collection of todos to render.
  # @return [String] The rendered partial.
  def todo_partials(partial, locals: {}, collection: nil)
    if collection.present?
      render partial: "todos/partials/#{partial}", collection: collection
    else
      render partial: "todos/partials/#{partial}", locals: locals
    end
  end

  # Generates the title for the todo modal.
  #
  # @param action [Symbol] The action to perform on the todo.
  # @return [String] The title for the todo modal.
  def todo_title_modal(action)
    case action
    when :new
      t('helpers.submit.new', model: Todo.model_name.human)
    when :edit
      t('helpers.submit.edit', model: Todo.model_name.human)
    when :show
      Todo.model_name.human
    when :delete
      t('messages.todo.delete')
    end
  end
end
