# encoding: utf-8

module Nanoc

  # TODO use this instead of ItemRepViewForRuleProcessing when filtering
  # TODO renaem this to ItemRepViewForFiltering

  # A wrapper around {Nanoc::Itemrep} that provides restricted access. Item rep
  # views should be used in assigns when filtering and layouting.
  class ItemRepView

    extend Forwardable

    def_delegators :@item_rep, :name, :compiled_content, :path, :raw_path

    # @param [Nanoc::ItemRep] item_rep
    # @param [Nanoc::ItemRepStore] item_rep_store
    def initialize(item_rep, item_rep_store)
      @item_rep       = item_rep
      @item_rep_store = item_rep_store
    end

    # @return [Nanoc::ItemRep] the item rep this view is for
    #
    # @api private
    def resolve
      @item_rep
    end

    # @return [Nanoc::ItemView] a view for the item for this rep
    def item
      Nanoc::ItemView.new(self.resolve.item, item_rep_store)
    end

    def inspect
      "<Nanoc::ItemRep* item.identifier=#{self.resolve.item.identifier.to_s.inspect} name=#{self.name.inspect}>"
    end

  end

end
