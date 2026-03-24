# frozen_string_literal: true

class ApplicationService
  attr_accessor :args

  def initialize(*args)
    @args = args
  end

  def self.call(*args)
    new(*args).call
  end

  def call
    raise NotImplementedError
  end
end
