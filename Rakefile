# frozen_string_literal: true

require 'bundler/gem_tasks'
require 'rdoc/task'

RDoc::Task.new :rdoc do |rdoc|
  rdoc.main = 'README.md'
  rdoc.rdoc_dir = 'doc'
  rdoc.title = 'BroadcastHub Documentation'
  rdoc.options << '--line-numbers' << '--inline-muted'
  rdoc.rdoc_files.include 'README.md', 'CHANGELOG.md', 'lib/**/*.rb'
end

begin
  require 'yard'
  YARD::Rake::YardocTask.new do |t|
    t.options = [ '--no-output' ]
  end
rescue LoadError
end
