source "http://rubygems.org"

gemspec

# TODO move this out of the Gemfile
gem 'ddplugin', :github => 'ddfreyne/ddplugin'

gem 'coveralls', :require => false

# When adding a group here, check .travis.yml’s `bundler_args`.

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
