# encoding: utf-8

module Nanoc

  # A collection of items. Allows fetching items using identifiers, e.g. `@items['/blah/']`.
  class ItemCollection

    # TODO allow mutating (keep a collection of mutations around)

    include Enumerable

    def initialize(data_sources, wrapper=nil)
      @data_sources = data_sources
      @wrapper      = wrapper || -> (i) { i }
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

    def glob(pattern)
      select { |i| i.identifier.match?(pattern) }.map { |i| wrap(i) }
    end

    def [](identifier)
      case identifier
      when String, Nanoc::Identifier
        wrap(item_with_identifier(identifier))
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

  protected

    def item_with_identifier(identifier)
      @data_sources.each do |ds|
        item = ds.item_with_identifier(identifier)
        return wrap(item) if item
      end
      nil
    end

    def wrap(item)
      @wrapper.call(item)
    end

  end

end
