# encoding: utf-8

module Nanoc

  # Stores checksums for objects in order to be able to detect whether a file
  # has changed since the last site compilation.
  #
  # @api private
  class ChecksumStore < ::Nanoc::AtomicNonLoadingStore

    def initialize
      super('tmp/checksums', 1)
    end

    # Returns the old checksum for the given object. This makes sense for
    # items, layouts and code snippets.
    #
    # @param [#reference] obj The object for which to fetch the checksum
    #
    # @return [String] The checksum for the given object
    def [](obj)
      super(obj.reference)
    end

    # Sets the checksum for the given object.
    #
    # @param [#reference] obj The object for which to set the checksum
    #
    # @param [String] checksum The checksum
    def []=(obj, checksum)
      super(obj.reference, checksum)
    end

  end

end
