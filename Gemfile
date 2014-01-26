source "http://rubygems.org"

gemspec

gem 'rubocop', :github => 'bbatsov/rubocop'

gem 'coveralls', :require => false

platforms :rbx do
  gem 'rubysl'
end

group :doc do
  gem 'kramdown'
  gem 'yard'
end

group :test do
  gem 'rake'
  gem 'minitest'
  gem 'mocha'
  gem 'systemu'
end
