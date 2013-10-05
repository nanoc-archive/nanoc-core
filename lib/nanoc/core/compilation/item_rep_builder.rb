# encoding: utf-8

module Nanoc

  class ItemRepBuilder

    def initialize(items, rules_collection, rule_memory_calculator, snapshot_store)
      @items                  = items
      @rules_collection       = rules_collection
      @rule_memory_calculator = rule_memory_calculator
      @snapshot_store         = snapshot_store
    end

    def populated_item_rep_store
      reps = []

      @items.each do |item|
        # Find matching rules
        matching_rules = @rules_collection.item_compilation_rules_for(item)
        if matching_rules.empty?
          raise Nanoc::Errors::NoMatchingCompilationRuleFound.new(item)
        end

        # Create reps
        rep_names = matching_rules.map { |r| r.rep_name }.uniq
        rep_names.each do |rep_name|
          rep = ItemRep.new(item, rep_name, :snapshot_store => @snapshot_store)

          @rule_memory_calculator.new_rule_memory_for_rep(rep)

          # FIXME paths_without_snapshot also includes paths with snapshots
          rep.paths_without_snapshot = @rule_memory_calculator.write_paths_for(rep)
          rep.paths                  = @rule_memory_calculator.snapshot_write_paths_for(rep)

          reps << rep
        end
      end

      Nanoc::ItemRepStore.new(reps)
    end

  end

end
