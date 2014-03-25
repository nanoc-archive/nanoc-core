# encoding: utf-8

module Nanoc

  # A collection of items. Allows fetchin items using identifiers, e.g. `@items['/blah/']`.
  class ItemCollection

    module Mutating

      def <<(item)
        @items << item
      end

      def clear
        @items.clear
      end

      def concat(items)
        @items.concat(items)
      end

      def delete(item)
        @items.delete(item)
      end

      def map!(&block)
        @items.map!(&block)
      end
      alias_method :collect!, :map!

      def delete_if(&block)
        @items.delete_if { |i| block.call(i) }
      end

      def reject!(&block)
        @items.reject! { |i| block.call(i) }
      end

      def select!(&block)
        self.reject! { |i| !block.call(i) }
      end

    end

    include Enumerable
    include Mutating

    def initialize
      @items = []
    end

    def inspect
      "<#{self.class} items=#{@items.inspect}>"
    end

    def eql?(other)
      @items.eql?(other)
    end
    alias_method :==, :eql?

    def hash
      @items.hash
    end

    def to_a
      @items
    end

    def freeze
      @items.freeze
      build_mapping
      super
    end

    def size
      @items.length
    end
    alias_method :length, :size

    def each(&block)
      @items.each { |i| block.call(i) }
    end

    def glob(pattern)
      @items.select { |i| i.identifier.match?(pattern) }
    end

    def [](s)
      case s
      when Nanoc::Identifier
        item_with_identifier(s)
      when String
        item_with_identifier(s) || glob_single(s)
      else
        raise Nanoc::Errors::Generic,
          'Can only call ItemCollection#[] with string or identifier'
      end
    end
    alias_method :slice, :[]
    alias_method :at,    :[]

    protected

    def item_with_identifier(identifier)
      if self.frozen?
        @mapping[identifier]
      else
        @items.find { |i| i.identifier == identifier }
      end
    end

    def glob_single(pattern)
      items = glob(pattern)
      case items.size
      when 0
        nil
      when 1
        items.first
      else
        raise Nanoc::Errors::MultipleObjectsMatchingPattern.new('items', pattern)
      end
    end

    def build_mapping
      @mapping = {}
      @items.each do |item|
        @mapping[item.identifier] = item
        @mapping[item.identifier.to_s] = item
      end
      @mapping.freeze
    end

  end

end
