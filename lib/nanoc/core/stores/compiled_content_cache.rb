# encoding: utf-8

module Nanoc

  # Represents a cache than can be used to store already compiled content,
  # to prevent it from being needlessly recompiled.
  #
  # @api private
  class CompiledContentCache < ::Nanoc::AtomicNonLoadingStore

    def initialize
      super('tmp/compiled_content', 1)

      @cache = {}
    end

    # Returns the cached compiled content for the given item
    # representation. This cached compiled content is a hash where the keys
    # are the snapshot names and the values the compiled content at the
    # given snapshot.
    #
    # @param [Nanoc::ItemRep] rep The item rep to fetch the content for
    #
    # @return [Hash<Symbol,String>] A hash containing the cached compiled
    #   content for the given item representation
    def [](rep)
      item_data = super(rep.item.identifier) || {}
      item_data[rep.name]
    end

    # Sets the compiled content for the given representation.
    #
    # @param [Nanoc::ItemRep] rep The item representation for which to set
    #   the compiled content
    #
    # @param [Hash<Symbol,String>] content A hash containing the compiled
    #   content of the given representation
    #
    # @return [void]
    def []=(rep, content)
      identifier = rep.item.identifier

      old_data = super.[](identifier) || {}
      new_data = old_data.merge({ rep.name => content })

      super(identifier, new_data)
    end

  end

end
