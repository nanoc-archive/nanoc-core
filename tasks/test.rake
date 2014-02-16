# encoding: utf-8

require './test/helper.rb'

FileList['./test/**/test_*.rb', './test/**/*_spec.rb'].each do |fn|
  require fn
end
