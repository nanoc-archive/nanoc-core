# encoding: utf-8

module Nanoc

  # @return [String] A string containing information about this nanoc version
  #   and its environment (Ruby engine and version, Rubygems version if any).
  def self.version_information
    gem_info = defined?(Gem) ? "with RubyGems #{Gem::VERSION}" : "without RubyGems"
    engine   = defined?(RUBY_ENGINE) ? RUBY_ENGINE : "ruby"
    res = ''
    res << "nanoc #{Nanoc::VERSION} © 2007-2013 Denis Defreyne.\n"
    res << "Running #{engine} #{RUBY_VERSION} (#{RUBY_RELEASE_DATE}) on #{RUBY_PLATFORM} #{gem_info}.\n"
    res
  end

end

# Load general requirements
require 'digest'
require 'enumerator'
require 'fileutils'
require 'forwardable'
require 'pathname'
require 'pstore'
require 'set'
require 'tempfile'
require 'thread'
require 'time'
require 'yaml'

# Load nanoc
require 'nanoc/core/version'
require 'nanoc/core/core_ext'
require 'nanoc/core/errors'

# Load helper classes
require 'nanoc/core/helper/context'
require 'nanoc/core/helper/directed_graph'
require 'nanoc/core/helper/memoization'
require 'nanoc/core/helper/notification_center'
require 'nanoc/core/helper/plugin_registry'
require 'nanoc/core/helper/filesystem_tools'

# Load entity classes
require 'nanoc/core/entities/code_snippet'
require 'nanoc/core/entities/content'
require 'nanoc/core/entities/configuration'
require 'nanoc/core/entities/document'
require 'nanoc/core/entities/item'
require 'nanoc/core/entities/item_array'
require 'nanoc/core/entities/item_rep'
require 'nanoc/core/entities/layout'
require 'nanoc/core/entities/identifier'
require 'nanoc/core/entities/pattern'
require 'nanoc/core/entities/site'

# Load proxy classes
require 'nanoc/core/proxies/item_proxy'

# Load store classes
require 'nanoc/core/store'
require 'nanoc/core/stores/data_source'
require 'nanoc/core/stores/snapshot_store'
require 'nanoc/core/stores/rules_store'
require 'nanoc/core/stores/filesystem_rules_store'
require 'nanoc/core/stores/checksum_store'
require 'nanoc/core/stores/compiled_content_cache'
require 'nanoc/core/stores/rule_memory_store'
require 'nanoc/core/stores/item_rep_writer'
require 'nanoc/core/stores/item_rep_store'

# Load interactor classes
require 'nanoc/core/interactors/site_loader'
require 'nanoc/core/interactors/pruner'

# Load compilation classes
require 'nanoc/core/compilation/compiler'
require 'nanoc/core/compilation/compiler_dsl'
require 'nanoc/core/compilation/dependency_tracker'
require 'nanoc/core/compilation/filter'
require 'nanoc/core/compilation/item_rep_recorder_proxy'
require 'nanoc/core/compilation/item_rep_rules_proxy'
require 'nanoc/core/compilation/outdatedness_checker'
require 'nanoc/core/compilation/outdatedness_reasons'
require 'nanoc/core/compilation/rule'
require 'nanoc/core/compilation/rule_context'
require 'nanoc/core/compilation/rule_memory_calculator'
require 'nanoc/core/compilation/rules_collection'

# Load files that are not yet pluginised
require 'nanoc/core/data_sources'
require 'nanoc/core/filters'
