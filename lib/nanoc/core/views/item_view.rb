# encoding: utf-8

module Nanoc

  # A wrapper around {Nanoc::Item} that provides restricted access.
  class ItemView < Nanoc::DocumentView

    extend Nanoc::Memoization

    # @param [Nanoc::Item] item
    # @param [Nanoc::ItemRepStore] item_rep_store
    def initialize(item, item_rep_store)
      super(item)
      @item_rep_store = item_rep_store
    end

    # @return [Boolean] true if the item is binary, false if it is not.
    def binary?
      resolve.binary?
    end

    # @return [Enumerable<Nanoc::ItemRepViewForFiltering>] This item’s collection of item reps
    def reps
      @item_rep_store.reps_for_item(resolve).map do |item_rep|
        Nanoc::ItemRepViewForFiltering.new(item_rep, @item_rep_store)
      end
    end
    memoize :reps

    # @param [Symbol] rep_name The name of the representation to return
    #
    # @return [Nanoc::ItemRepViewForFiltering] The representation with the given name
    def rep_named(rep_name)
      self.reps.find { |r| r.name == rep_name }
    end

    # Returns the compiled content from a given representation and a given
    # snapshot. This is a convenience method that makes fetching compiled
    # content easier.
    #
    # @option params [String] :rep (:default) The name of the representation
    #   from which the compiled content should be fetched. By default, the
    #   compiled content will be fetched from the default representation.
    #
    # @option params [String] :snapshot The name of the snapshot from which to
    #   fetch the compiled content. By default, the returned compiled content
    #   will be the content compiled right before the first layout call (if
    #   any).
    #
    # @return [String] The compiled content of the given rep (or the default
    #   rep if no rep is specified) at the given snapshot (or the default
    #   snapshot if no snapshot is specified)
    #
    # @see ItemRep#compiled_content
    def compiled_content(params={})
      rep_for_params!(params).compiled_content(params)
    end

    # Returns the path from a given representation. This is a convenience
    # method that makes fetching the path of a rep easier.
    #
    # @option params [String] :rep (:default) The name of the representation
    #   from which the path should be fetched. By default, the path will be
    #   fetched from the default representation.
    #
    # @return [String] The path of the given rep ( or the default rep if no
    #   rep is specified)
    def path(params={})
      rep_for_params!(params).path(params)
    end

    # TODO document
    def rep_for_params!(params={})
      rep_name = params.fetch(:rep, :default)

      rep = self.reps.find { |r| r.name == rep_name }
      if rep.nil?
        raise Nanoc::Errors::Generic,
          "No rep named #{rep_name.inspect} was found."
      end

      rep
    end

    # TODO remove me (used in capturing helper)
    def forced_outdated=(bool) ; resolve.forced_outdated = bool ; end

  end

end
