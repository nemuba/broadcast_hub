# frozen_string_literal: true

# TodosController
class TodosController < ApplicationController
  before_action :set_todo, only: %i[show edit update destroy confirm_delete highlight inline more]
  before_action :instance_todo, only: %i[create]

  # GET /todos or /todos.json
  def index
    @todos = TodoService.call(params, current_user)

    respond_to do |format|
      format.html { render 'index' }
      format.js { render 'todos/js/index' }
      format.json { render json: @todos, each_serializer: TodoSerializer, status: :ok }
    end
  end

  def datatable
    @todos = TodoService.call(params, current_user)

    send_data render_to_string(partial: 'todos/partials/todo', collection: @todos)
  end

  def more
    respond_to do |format|
      format.js { render 'todos/js/more' }
    end
  end

  # GET /todos/1 or /todos/1.json
  def show
    respond_to do |format|
      format.js { render 'todos/js/show' }
      format.json { render json: @todo, serializer: TodoSerializer, status: :ok }
    end
  end

  # GET /todos/new
  def new
    @todo = current_user.todos.build

    respond_to do |format|
      format.js { render 'todos/js/new' }
    end
  end

  # GET /todos/1/edit
  def edit
    respond_to do |format|
      format.js { render 'todos/js/edit' }
    end
  end

  # POST /todos or /todos.json
  def create
    @todo.save

    respond_to do |format|
      format.js { render 'todos/js/create' }
      format.json { render json: @todo, serializer: TodoSerializer, status: :ok }
    end
  end

  # PATCH/PUT /todos/1 or /todos/1.json
  def update
    @todo.update(todo_params)

    respond_to do |format|
      format.js { render 'todos/js/update' }
      format.json { render json: @todo, serializer: TodoSerializer, status: :ok }
    end
  end

  # GET /todos/1/confirm_delete
  def confirm_delete
    respond_to do |format|
      format.js { render 'todos/js/confirm_delete' }
    end
  end

  # DELETE /todos/1 or /todos/1.json
  def destroy
    @todo.destroy

    respond_to do |format|
      format.js { render 'todos/js/destroy' }
    end
  end

  def inline
    respond_to do |format|
      format.js { render 'todos/js/inline' }
    end
  end

  def highlight
    respond_to do |format|
      format.js { broadcast_todo_highlight }
      format.json { broadcast_todo_highlight }
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_todo
    @todo = current_user.todos.find(params[:id])
  end

  def instance_todo
    @todo = current_user.todos.build(todo_params)
  end

  # Only allow a list of trusted parameters through.
  def todo_params
    params.require(:todo).permit(:title, :description, :status, :inline_editing)
  end

  def broadcast_todo_highlight
    render_broadcast(
      action: 'dispatch',
      target: "##{ActionView::RecordIdentifier.dom_id(@todo)}",
      resource: 'todo',
      event_name: 'todo:highlight',
      event_data: { id: @todo.id, title: @todo.title }
    )
  end
end
