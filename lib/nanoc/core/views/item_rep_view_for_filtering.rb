# encoding: utf-8

module Nanoc

  # A wrapper around {Nanoc::ItemRep} that provides restricted access during filtering.
  class ItemRepViewForFiltering

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
