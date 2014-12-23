# encoding: utf-8

module Nanoc
  # A wrapper around {Nanoc::Item} that provides restricted access during
  # preprocessing.
  class ItemViewForPreprocessing < Nanoc::DocumentView
    # @return [Boolean] true if the item is binary, false if it is not.
    def binary?
      resolve.binary?
    end

    # Requests the attribute with the given key.
    #
    # @param [Symbol] key The name of the attribute to fetch
    #
    # @return The value of the requested attribute
    def [](key)
      resolve.attributes[key]
    end

    # Sets the attribute with the given key to the given value.
    #
    # @param [Symbol] key The name of the attribute to set
    #
    # @param value The value of the attribute to set
    #
    # @return [void]
    def []=(key, value)
      resolve.attributes[key] = value
    end
  end
end
