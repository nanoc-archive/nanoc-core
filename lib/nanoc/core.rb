# encoding: utf-8

module Nanoc

  # @return [String] A string containing information about this nanoc version
  #   and its environment (Ruby engine and version, Rubygems version if any).
  def self.version_information
    gem_info = defined?(Gem) ? "with RubyGems #{Gem::VERSION}" : 'without RubyGems'
    engine   = defined?(RUBY_ENGINE) ? RUBY_ENGINE : 'ruby'
    res = ''
    res << "nanoc #{Nanoc::VERSION} © 2007-2014 Denis Defreyne.\n"
    res << "Running #{engine} #{RUBY_VERSION} (#{RUBY_RELEASE_DATE}) on #{RUBY_PLATFORM} #{gem_info}.\n"
    res
  end

  # @return [Boolean] True if the current platform is Windows,
  def self.on_windows?
    RUBY_PLATFORM =~ /windows|bccwin|cygwin|djgpp|mingw|mswin|wince/i
  end

end

# Load external libraries
require 'ddplugin'

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
require 'English'

# Load nanoc
require 'nanoc/core/version'
require 'nanoc/core/core_ext'
require 'nanoc/core/errors'

# Load helper classes
require 'nanoc/core/helper/context'
require 'nanoc/core/helper/directed_graph'
require 'nanoc/core/helper/memoization'
require 'nanoc/core/helper/notification_center'
require 'nanoc/core/helper/filesystem_tools'

# Load entity classes
require 'nanoc/core/entities/binary_content'
require 'nanoc/core/entities/code_snippet'
require 'nanoc/core/entities/content'
require 'nanoc/core/entities/configuration'
require 'nanoc/core/entities/document'
require 'nanoc/core/entities/item'
require 'nanoc/core/entities/item_collection'
require 'nanoc/core/entities/item_rep'
require 'nanoc/core/entities/layout'
require 'nanoc/core/entities/identifier'
require 'nanoc/core/entities/pattern'
require 'nanoc/core/entities/site'
require 'nanoc/core/entities/textual_content'
require 'nanoc/core/entities/rule_memory'
require 'nanoc/core/entities/rule_memory_action'
require 'nanoc/core/entities/rule_memory_actions'

# Load view classes
require 'nanoc/core/views/document_view'
require 'nanoc/core/views/item_view'
require 'nanoc/core/views/item_view_for_preprocessing'
require 'nanoc/core/views/item_rep_view_for_filtering'
require 'nanoc/core/views/item_rep_view_for_recording'
require 'nanoc/core/views/item_rep_view_for_rule_processing'
require 'nanoc/core/views/layout_view'

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
require 'nanoc/core/interactors/compiler_builder'
require 'nanoc/core/interactors/item_rep_compilation_selector'
require 'nanoc/core/interactors/site_loader'
require 'nanoc/core/interactors/preprocessor'
require 'nanoc/core/interactors/pruner'
require 'nanoc/core/interactors/checksummer'

# Load compilation classes
require 'nanoc/core/compilation/compiler'
require 'nanoc/core/compilation/compiler_dsl'
require 'nanoc/core/compilation/dependency_tracker'
require 'nanoc/core/compilation/filter'
require 'nanoc/core/compilation/item_rep_builder'
require 'nanoc/core/compilation/outdatedness_checker'
require 'nanoc/core/compilation/outdatedness_reasons'
require 'nanoc/core/compilation/rule'
require 'nanoc/core/compilation/rule_context'
require 'nanoc/core/compilation/rule_memory_calculator'
require 'nanoc/core/compilation/rules_collection'

# Load files that are not yet pluginised
require 'nanoc/core/data_sources'
require 'nanoc/core/filters'
