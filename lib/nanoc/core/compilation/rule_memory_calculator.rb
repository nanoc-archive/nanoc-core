# encoding: utf-8

module Nanoc

  # Calculates rule memories for objects that can be run through a rule (item
  # representations and layouts).
  #
  # @api private
  class RuleMemoryCalculator

    extend Nanoc::Memoization

    # @param [Nanoc::Site] site
    #
    # @param [Nanoc::RulesCollection] rules_collection
    #
    # @param [Nanoc::RuleMemoryStore] rule_memory_store
    def initialize(site, rules_collection, rule_memory_store)
      @site              = site
      @rules_collection  = rules_collection
      @rule_memory_store = rule_memory_store
    end

    # @param [#reference] obj The object to calculate the rule memory for
    #
    # @return [Array] The calculated rule memory for the given object
    def [](obj)
      result =
        case obj.type
        when :item_rep
          self.new_rule_memory_for_rep(obj).serialize
        when :layout
          self.new_rule_memory_for_layout(obj)
        else
          raise "Do not know how to calculate the rule memory for #{obj.inspect}"
        end

      result
    end
    memoize :[]

    # @param [Nanoc::ItemRep] rep The item representation to get the rule
    #   memory for
    #
    # @return [Array] The rule memory for the given item representation
    def new_rule_memory_for_rep(rep)
      view_for_recording = rep.to_view_for_recording
      @rules_collection.compilation_rule_for(rep).apply_to(view_for_recording, @site)
      view_for_recording.rule_memory
    end
    memoize :new_rule_memory_for_rep

    # @param [Nanoc::Layout] layout The layout to get the rule memory for
    #
    # @return [Array] The rule memory for the given layout
    def new_rule_memory_for_layout(layout)
      @rules_collection.filter_for_layout(layout)
    end
    memoize :new_rule_memory_for_layout

    # @param [Nanoc::ItemRep] rep The item representation for which to fetch
    #   the list of snapshots
    #
    # @return [Array] A list of snapshots, represented as arrays where the
    #   first element is the snapshot name (a Symbol) and the last element is
    #   a Boolean indicating whether the snapshot is final or not
    def snapshots_for(rep)
      mem = new_rule_memory_for_rep(rep)

      names_1 =
        mem.select { |s| s.is_a?(Nanoc::RuleMemoryActions::Snapshot) }.
            map    { |s| [ s.snapshot_name, s.final? ] }

      names_2 =
        mem.select { |s| s.is_a?(Nanoc::RuleMemoryActions::Write) && s.snapshot? }.
            map    { |s| [ s.snapshot_name, true ] }

      names_1 + names_2
    end

    def write_paths_for(rep)
      mem = new_rule_memory_for_rep(rep)

      paths_from_writes = mem.
        select { |s| s.is_a?(Nanoc::RuleMemoryActions::Write) }.
        map    { |s| s.path.to_s }

      paths_from_snapshots = mem.
        select { |s| s.is_a?(Nanoc::RuleMemoryActions::Snapshot) && s.path? }.
        map    { |s| s.path.to_s }

      paths_from_writes + paths_from_snapshots
    end

    def snapshot_write_paths_for(rep)
      mem = new_rule_memory_for_rep(rep)

      writes = mem.
        select { |s| s.is_a?(Nanoc::RuleMemoryActions::Write) && s.snapshot? }.
        each_with_object({}) { |s, memo| memo[s.snapshot_name] = s.path.to_s }

      snapshots = mem.
        select { |s| s.is_a?(Nanoc::RuleMemoryActions::Snapshot) && s.path? }.
        each_with_object({}) { |s, memo| memo[s.snapshot_name] = s.path.to_s }

      writes.merge(snapshots)
    end

    # @param [Nanoc::Item] obj The object for which to check the rule memory
    #
    # @return [Boolean] true if the rule memory for the given object has
    # changed since the last compilation, false otherwise
    def rule_memory_differs_for(obj)
      !@rule_memory_store[obj].eql?(self[obj])
    end
    memoize :rule_memory_differs_for

  end

end
