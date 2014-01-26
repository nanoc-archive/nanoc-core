# encoding: utf-8

module Nanoc

  # A collection of items. Allows fetching items using identifiers, e.g. `@items['/blah/']`.
  class ItemCollection

    # TODO allow mutating (keep a collection of mutations around)
    #
    # Structure of mutation data structure:
    #
    # IDEA 1:
    #   hash map with keys = identifiers and values = mutated item
    #   advantages: easy
    #   disadvantages: not memory efficient
    #
    # IDEA 2:
    #   Store modifications as lambdas with globs that define which items it
    #     applies to.
    #   advantages: memory efficient
    #   disadvantages: harder to debug

    include Enumerable

    def initialize(data_sources, wrapper=nil)
      @data_sources = data_sources
      @wrapper      = wrapper || ->(i) { i }
    end

    def wrapped(wrapper)
      self.class.new(@data_sources, wrapper)
    end

    def eql?(other)
      @data_sources.eql?(other)
    end
    alias_method :==, :eql?

    def hash
      super ^ @data_sources.hash
    end

    def glob(patternish)
      pattern = Nanoc::Pattern.from(patternish)
      @data_sources.flat_map do |ds|
        ds.glob_items(pattern).map { |i| wrap(i) }
      end
    end

    def [](identifier)
      case identifier
      when String, Nanoc::Identifier
        @data_sources.each do |ds|
          item = ds.item_with_identifier(identifier)
          return wrap(item) if item
        end
        nil
      else
        raise Nanoc::Errors::Generic, "Can only call ItemCollection#[] with string or identifier"
      end
    end
    alias_method :slice, :[]
    alias_method :at,    :[]

    def each
      @data_sources.each do |ds|
        ds.items.each { |i| yield(wrap(i)) }
      end
    end

    # @see Object#inspect
    def inspect
      # FIXME this should not have to iterate over all items
      "<#{self.class} item_identifiers=#{self.map { |i| i.identifier }.join(',')}>"
    end

  protected

    def wrap(item)
      @wrapper.call(item)
    end

  end

end
