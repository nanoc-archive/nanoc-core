# encoding: utf-8

module Nanoc

  # Generates compilers.
  #
  # @api private
  class CompilerBuilder

    def build(site)
      dependency_tracker     = self.build_dependency_tracker(site)
      rules_store            = self.build_rules_store(site.config)
      checksum_store         = self.build_checksum_store
      compiled_content_cache = self.build_compiled_content_cache
      rule_memory_store      = self.build_rule_memory_store(site)
      snapshot_store         = self.build_snapshot_store(site.config)
      item_rep_writer        = self.build_item_rep_writer(site.config)
      rule_memory_calculator = self.build_rule_memory_calculator(site, rules_store.rules_collection, rule_memory_store)
      item_rep_store         = self.build_item_rep_store(site.items, rules_store.rules_collection, rule_memory_calculator, snapshot_store)
      outdatedness_checker   = self.build_outdatedness_checker(site, checksum_store, dependency_tracker, item_rep_writer, item_rep_store, rule_memory_calculator)
      preprocessor           = self.build_preprocessor(site, rules_store.rules_collection)

      Nanoc::Compiler.new(
        site,
        dependency_tracker:     dependency_tracker,
        rules_store:            rules_store,
        checksum_store:         checksum_store,
        compiled_content_cache: compiled_content_cache,
        rule_memory_store:      rule_memory_store,
        snapshot_store:         snapshot_store,
        item_rep_writer:        item_rep_writer,
        rule_memory_calculator: rule_memory_calculator,
        item_rep_store:         item_rep_store,
        outdatedness_checker:   outdatedness_checker,
        preprocessor:           preprocessor)
    end

    protected

    def build_dependency_tracker(site)
      Nanoc::DependencyTracker.new(site.items, site.layouts).tap { |s| s.load }
    end

    def build_rules_store(config)
      rules_collection = Nanoc::RulesCollection.new

      identifier = config.fetch(:rules_store_identifier, :filesystem)
      klass = Nanoc::RulesStore.named(identifier)
      rules_store = klass.new(rules_collection)

      rules_store.load_rules

      rules_store
    end

    def build_checksum_store
      Nanoc::ChecksumStore.new.tap { |s| s.load }
    end

    def build_compiled_content_cache
      Nanoc::CompiledContentCache.new.tap { |s| s.load }
    end

    def build_rule_memory_store(site)
      Nanoc::RuleMemoryStore.new(site: site).tap { |s| s.load }
    end

    def build_snapshot_store(config)
      name = config.fetch(:store_type, :in_memory)
      klass = Nanoc::SnapshotStore.named(name)
      klass.new
    end

    def build_item_rep_writer(config)
      # TODO pass options the right way
      # TODO make type customisable (:filesystem)
      Nanoc::ItemRepWriter.named(:filesystem).new({ :output_dir => config[:output_dir] })
    end

    def build_rule_memory_calculator(site, rules_collection, rule_memory_store)
      Nanoc::RuleMemoryCalculator.new(site, rules_collection, rule_memory_store)
    end

    def build_item_rep_store(items, rules_collection, rule_memory_calculator, snapshot_store)
      builder = Nanoc::ItemRepBuilder.new(items, rules_collection, rule_memory_calculator, snapshot_store)
      builder.populated_item_rep_store
    end

    def build_outdatedness_checker(site, checksum_store, dependency_tracker, item_rep_writer, item_rep_store, rule_memory_calculator)
      Nanoc::OutdatednessChecker.new(
        :site                   => site,
        :checksum_store         => checksum_store,
        :dependency_tracker     => dependency_tracker,
        :item_rep_writer        => item_rep_writer,
        :item_rep_store         => item_rep_store,
        :rule_memory_calculator => rule_memory_calculator)
    end

    def build_preprocessor(site, rules_collection)
      Nanoc::Preprocessor.new(site, rules_collection)
    end

  end

end
