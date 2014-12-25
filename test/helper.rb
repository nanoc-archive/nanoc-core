# encoding: utf-8

# Setup code coverage
require 'simplecov'
require 'coveralls'
SimpleCov.formatter = SimpleCov::Formatter::MultiFormatter[
  SimpleCov::Formatter::HTMLFormatter,
  Coveralls::SimpleCov::Formatter,
]
SimpleCov.start

# Load unit testing stuff
require 'minitest/autorun'
require 'mocha/setup'
require 'yard'

# Load nanoc
require 'nanoc-core'

# Load miscellaneous requirements
require 'stringio'
require 'tmpdir'

module Nanoc::TestHelpers
  LIB_DIR = File.expand_path(File.dirname(__FILE__) + '/../lib')

  def in_site(params = {})
    # Build site name
    site_name = params[:name]
    if site_name.nil?
      @site_num ||= 0
      site_name = "site-#{@site_num}"
      @site_num += 1
    end

    # Create site
    unless File.directory?(site_name)
      FileUtils.mkdir_p(site_name)
      FileUtils.cd(site_name) do
        create_site_here(params)
      end
    end

    # Yield site
    FileUtils.cd(site_name) do
      yield
    end
  end

  def site_here
    Nanoc::SiteLoader.new.load
  end

  def compile_site_here
    Nanoc::CompilerBuilder.new.build(site_here).run
  end

  def create_site_here(params = {})
    # Build rules
    rules_content = <<EOS
compile '/**/*' do
  {{compilation_rule_content}}

  if item.binary?
    write item.identifier, :snapshot => :last
  elsif item.identifier.match?('/index.*')
    write '/index.html', :snapshot => :last
  else
    write item.identifier.without_ext + '/index.html', :snapshot => :last
  end
end

layout '/**/*', :erb
EOS
    rules_content.gsub!('{{compilation_rule_content}}', params[:compilation_rule_content] || '')

    FileUtils.mkdir_p('content')
    FileUtils.mkdir_p('layouts')
    FileUtils.mkdir_p('lib')
    FileUtils.mkdir_p('build')

    if params[:has_layout]
      File.open('layouts/default.html', 'w') do |io|
        io.write('... <%= @yield %> ...')
      end
    end

    File.write('nanoc.yaml', 'stuff: 12345')
    File.write('Rules', rules_content)
  end

  def setup
    # Enter tmp
    @tmp_dir = Dir.mktmpdir('nanoc-test')
    @orig_wd = FileUtils.pwd
    FileUtils.cd(@tmp_dir)
  end

  def teardown
    # Exit tmp
    FileUtils.cd(@orig_wd)
    FileUtils.rm_rf(@tmp_dir)
  end

  # Adapted from http://github.com/lsegal/yard-examples/tree/master/doctest
  def assert_examples_correct(object)
    P(object).tags(:example).each do |example|
      # Classify
      lines = example.text.lines.map do |line|
        [line =~ /^\s*# ?=>/ ? :result : :code, line]
      end

      # Join
      pieces = []
      lines.each do |line|
        if !pieces.empty? && pieces.last.first == line.first
          pieces.last.last << line.last
        else
          pieces << line
        end
      end
      lines = pieces.map(&:last)

      # Test
      b = binding
      lines.each_slice(2) do |pair|
        actual_out   = eval(pair.first, b)
        expected_out = eval(pair.last.match(/# ?=>(.*)/)[1], b)

        assert_equal expected_out, actual_out,
          "Incorrect example:\n#{pair.first}"
      end
    end
  end

  def assert_set_equal(actual, expected)
    assert_equal Set.new(actual), Set.new(expected)
  end

  def assert_raises_frozen_error
    error = assert_raises(RuntimeError, TypeError) { yield }
    assert_match(/(^can't modify frozen |^unable to modify frozen object$)/, error.message)
  end

  def on_windows?
    Nanoc.on_windows?
  end

  def symlink_supported?
    File.symlink(nil, nil)
  rescue NotImplementedError
    return false
  rescue
    return true
  end

  def skip_unless_symlinks_supported
    skip 'Symlinks are not supported by Ruby on Windows' unless symlink_supported?
  end
end

class Nanoc::TestCase < Minitest::Test
  include Nanoc::TestHelpers
end

# Unexpected system exit is unexpected
::Minitest::Test::PASSTHROUGH_EXCEPTIONS.delete(SystemExit)

# A more precise inspect method for Time improves assert failure messages.
#
class Time
  def inspect
    strftime("%a %b %d %H:%M:%S.#{format('%06d', usec)} %Z %Y")
  end
end
