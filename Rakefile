# encoding: utf-8

require 'yard'
require 'rubocop/rake_task'

YARD::Rake::YardocTask.new(:doc) do |yard|
  yard.files   = Dir['lib/**/*.rb']
  yard.options = [
    '--markup',          'markdown',
    '--markup-provider', 'kramdown',
    '--charset',         'utf-8',
    '--readme',          'README.md',
    '--files',           'NEWS.md,LICENSE',
    '--output-dir',      'doc/yardoc',
    '--template-path',   'doc/yardoc_templates',
    '--load',            'doc/yardoc_handlers/identifier.rb'
  ]
end

Rubocop::RakeTask.new(:rubocop) do |task|
  task.patterns = ['lib/**/*.rb']
end

task :test do
  require './test/helper.rb'

  FileList['./test/**/test_*.rb', './test/**/*_spec.rb'].each do |fn|
    require fn
  end
end

task :default => :test
