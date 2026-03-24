# frozen_string_literal: true

module ApplicationHelper
  # Generate a DOM id for a given Active Record object.
  # If a prefix is provided, it will be used instead of the class name.
  # Example:
  #   dom_id(@user) # => "user_1"
  #   dom_id(@user, "profile") # => "profile_1"
  # This method is useful for generating unique IDs for HTML elements associated with specific records.
  # @param record [ActiveRecord::Base] The Active Record object for which to generate the DOM id.
  # @param prefix [String, nil] An optional prefix to use instead of the class name.
  # @return [String] The generated DOM id.
  def dom_id(record, prefix = nil)
    prefix ||= record.class.name.underscore
    "#{prefix}_#{record.id}"
  end
end
