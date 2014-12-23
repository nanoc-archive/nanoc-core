# encoding: utf-8

module Nanoc
  # Has content, attributes and an identifier.
  class Document
    extend Nanoc::Memoization

    # @return [Nanoc::Identifier]
    attr_accessor :identifier

    # @return [Nanoc::Content] This content piece's raw content
    attr_reader :content

    # @return [Hash]
    attr_accessor :attributes

    # @return [Nanoc::Site] The site this content piece belongs to
    attr_accessor :site

    # Creates a new content piece with the given content, attributes and
    # identifier.
    #
    # @param [Nanoc::Content] content The uncompiled content
    #
    # @param [Hash] attributes
    #
    # @param [String] identifier This content piece's identifier.
    def initialize(content, attributes, identifier)
      # Content
      if content.nil?
        raise ArgumentError, "Attempted to create a #{self.class} without content (identifier #{identifier})"
      elsif content.is_a?(Nanoc::TextualContent) || content.is_a?(Nanoc::BinaryContent)
        @content = content
      else
        # FIXME: does it make sense to have a nil path?
        @content = Nanoc::TextualContent.new(content.to_s, nil)
      end

      # Attributes
      @attributes = attributes.symbolize_keys_recursively

      # Identifier
      if identifier.is_a?(Nanoc::Identifier)
        @identifier = identifier
      else
        @identifier = Nanoc::Identifier.from_string(identifier.to_s)
      end
    end

    def binary?
      content.binary?
    end

    # @return [Symbol] the type of this object as a symbol (`:item`, `:layout`, ...)
    #
    # @api private
    #
    # @abstract
    def type
      raise NotImplementedError
    end

    # Returns an object that can be used for uniquely identifying objects.
    #
    # @api private
    #
    # @return [Object] An unique reference to this object
    def reference
      [type, identifier]
    end

    # @see Object#freeze
    def freeze
      super
      attributes.freeze_recursively
      identifier.freeze
      content.freeze
    end

    # @see Object#inspect
    def inspect
      "<#{self.class} identifier=#{identifier.inspect}>"
    end

    # @see Object#hash
    def hash
      self.class.hash ^ identifier.hash
    end

    # @see Object#eql?
    def eql?(other)
      self.class == other.class && identifier == other.identifier
    end

    # @see Object#==
    def ==(other)
      self.eql?(other)
    end
  end
end
