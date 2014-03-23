# encoding: utf-8

module Nanoc

  # Represents a fake iem representation that does not actually perform any
  # actual filtering, layouting or snapshotting, but instead keeps track of
  # what would happen if a real item representation would have been used
  # instead. It therefore “records” the actions that happens upon it.
  #
  # The list of recorded actions is used during compilation to determine
  # whether an item representation needs to be recompiled: if the list of
  # actions is different from the list of actions from the previous
  # compilation run, the item needs to be recompiled; if it is the same, it
  # may not need to be recompiled.
  #
  # @api private
  class ItemRepViewForRecording

    extend Forwardable

    def_delegators :@item_rep, :name, :binary, :binary?, :compiled_content, :has_snapshot?, :path, :assigns, :assigns=

    # @return [Nanoc::RuleMemory] The list of recorded actions (“rule memory”)
    attr_reader :rule_memory

    # @param [Nanoc::ItemRep] item_rep The item representation that this
    #   proxy should behave like
    def initialize(item_rep)
      @item_rep    = item_rep

      @rule_memory = Nanoc::RuleMemory.new(item_rep)
    end

    # @return [Nanoc::ItemRep] the item rep this view is for
    #
    # @api private
    def resolve
      @item_rep
    end

    # @return [Nanoc::ItemView] A view for this item rep’s item
    def item
      Nanoc::ItemView.new(@item_rep.item, nil)
    end

    # @return [void]
    #
    # @see Nanoc::ItemRepViewForRuleProcessing#filter, Nanoc::ItemRep#filter
    def filter(name, args = {})
      @rule_memory.add_filter(name, args)
    end

    # @return [void]
    #
    # @see Nanoc::ItemRepViewForRuleProcessing#layout, Nanoc::ItemRep#layout
    def layout(layout_identifier, extra_filter_args = nil)
      @rule_memory.add_layout(layout_identifier, extra_filter_args)
    end

    # @return [void]
    #
    # @see Nanoc::ItemRep#snapshot
    def snapshot(snapshot_name, params = {})
      @rule_memory.add_snapshot(
        snapshot_name,
        params.fetch(:path, nil),
        params.fetch(:final, true))
    end

    # TODO document
    def write(path, params = {})
      @rule_memory.add_write(
        path,
        params.fetch(:snapshot, nil))
    end

    # @return [{}]
    def content
      {}
    end

  end

end
