# frozen_string_literal: true

# TodoService
class TodoService < ApplicationService
  attr_accessor :params, :user

  def initialize(*args)
    @params = args.first
    @user = args.last
    super(args)
  end

  def call
    return sort if sort?
    return search if search?

    user.todos.limit(50)
  end

  private

  def search
    if status?
      user.todos.where(status: params[:status]).limit(50)
    else
      user.todos.search(field, params[field]).limit(50)
    end
  end

  def sort
    user.todos.order_by(params[:sort], params[:direction])
  end

  def field
    title? ? 'title' : 'description'
  end

  def search?
    params.keys.any? { |key| key.in? %w[title description status] }
  end

  def sort?
    params.keys.any? { |key| key.in? %w[sort direction] }
  end

  def title?
    params[:title].present?
  end

  def description?
    params[:description].present?
  end

  def status?
    params[:status].present?
  end
end
