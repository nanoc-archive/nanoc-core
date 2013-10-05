# encoding: utf-8

module Nanoc

  # Generates compilers.
  #
  # @api private
  class CompilerBuilder

    def initialize(site)
      @site = site
    end

    def build
      dependency_tracker = self.build_dependency_tracker
      rules_store        = self.build_rules_store(@site.config)

      Nanoc::Compiler.new(
        @site,
        dependency_tracker: dependency_tracker,
        rules_store:        rules_store)
    end

    protected

    def build_dependency_tracker
      # TODO pass @site as param
      Nanoc::DependencyTracker.new(@site.items + @site.layouts)
    end

    def build_rules_store(config)
      rules_collection = Nanoc::RulesCollection.new

      identifier = config.fetch(:rules_store_identifier, :filesystem)
      klass = Nanoc::RulesStore.named(identifier)
      rules_store = klass.new(rules_collection)

      rules_store.load_rules

      rules_store
    end

  end

end
