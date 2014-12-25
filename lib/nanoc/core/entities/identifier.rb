# encoding: utf-8

module Nanoc
  # Used for identifying items and layouts.
  #
  # An identifier resembles a filesystem path quite closely: it is a list of
  # strings separated by slashes. The last component can have an extension.
  #
  # Some examples of identifiers:
  #
  #     /doc/tutorial.md
  #     /index.html
  class Identifier
    # @return [Array<String>] The components of this identifier.
    attr_reader :components

    # Creates an identifier from a string.
    #
    # @param [String] string The string to build an identifier from. It should
    #   be in the format "/foo/bar.ext".
    #
    # @return [Nanoc::Identifier]
    def self.from_string(string)
      if string =~ /\/$/
        raise Nanoc::Errors::IdentifierCannotEndWithSlashError.new(string)
      end

      components = string.split('/').reject(&:empty?)
      new(components)
    end

    # Attempts to coerce the input object into a Nanoc::Identifier. This
    # currently works for objects that are strings and objects that already are
    # identifiers.
    #
    # @param [String,Nanoc::Identifier] input
    #
    # @return [Nanoc::Identifier]
    def self.coerce(input)
      if input.is_a?(String)
        from_string(input)
      elsif input.is_a?(Nanoc::Identifier)
        return input
      else
        raise Nanoc::Errors::Generic "Do not know how to coerce #{input.inspect} into a Nanoc::Identifier"
      end
    end

    # @param [Array<String>] components
    def initialize(components)
      @components = components

      @components.freeze
      @components.each(&:freeze)
    end

    # @return [String] The string representation of this identifier, starting
    #   with a slash followed by all components separated by a slash
    #
    # @example
    #
    #   Nanoc::Identifier.new(%w( foo bar index.html )).to_s
    #   # => '/foo/bar/index.html'
    def to_s
      '/' + components.join('/')
    end

    # @param [String] other The string to append
    #
    # @return [String] A new string containing the identifier as a string,
    #   followed by the given string
    #
    # @example
    #
    #   identifier = Nanoc::Identifier.coerce('/foo/bar.md')
    #   identifier.without_ext + '-v123.' + identifier.extension
    #   # => '/foo/bar-v123.md'
    def +(other)
      to_s + other
    end

    # @!group Creating new instances

    # @return [Nanoc::Identifier, nil] A copy of the identifier with the last
    #   component removed, or nil if the identifier has no components.
    #
    # @example
    #
    #   Nanoc::Identifier.from_string('/foo/bar.md').parent.to_s
    #   # => '/foo'
    def parent
      parent_components = components[0..-2]
      if parent_components.empty?
        nil
      else
        self.class.new(parent_components)
      end
    end

    # FIXME: ugly
    def prefix(prefix)
      self.class.from_string(prefix + to_s)
    end

    # @param [String] string The component to append
    #
    # @return [Nanoc::Identifier] A copy of the identifier with the given
    #   component appended.
    #
    # @example
    #
    #   Nanoc::Identifier.from_string('/foo').append_component('bar').to_s
    #   # => '/foo/bar'
    def append_component(string)
      self.class.new(components + [string])
    end

    # @param [String] ext
    #
    # @return [Nanoc::Identifier] A new identifier with the given extension. If
    #   the identifier already had an extension, it is removed.
    #
    # @example
    #
    #   Nanoc::Identifier.coerce('/foo/bar.md').with_ext('html').to_s
    #   # => '/foo/bar.html'
    def with_ext(ext)
      cs = without_ext.components.dup
      cs[-1] = cs[-1] + '.' + ext
      self.class.new(cs)
    end

    # @return [Nanoc::Identifier] A new identifier with the extension removed
    #
    # @example
    #
    #   Nanoc::Identifier.coerce('/foo/bar.md').without_ext.to_s
    #   # => '/foo/bar'
    def without_ext
      cs = components.dup
      cs[-1] = cs[-1].sub(/\.\w+$/, '')
      self.class.new(cs)
    end

    # @return [Nanoc::Identifier] A new identifier with the extension removed,
    #   an 'index' component added, followed by the original extension
    #
    # @example
    #
    #   Nanoc::Identifier.from_string('/foo/bar.html').in_dir.to_s
    #   # => '/foo/bar/index.html'
    def in_dir
      base = without_ext.append_component('index')
      if extension
        base.with_ext(extension)
      else
        base
      end
    end

    # @!group Accessing

    # @return [String, nil] The extension, or nil if there is none
    #
    # @example
    #
    #   Nanoc::Identifier.coerce('/foo/bar.adoc').extension
    #   # => 'adoc'
    def extension
      c = components[-1]
      idx = c.rindex('.')
      if idx
        c[idx + 1..-1]
      else
        nil
      end
    end

    # @!group Testing

    # @param [Nanoc::Pattern] pattern
    #
    # @return [Boolean] true if the identifier matches the given pattern, false
    #   otherwise
    #
    # @example
    #
    #   identifier = Nanoc::Identifier.from_string('/foo/bar.md')
    #   pattern = Nanoc::Pattern.from('/foo/*.md')
    #   identifier.match?(pattern)
    #   # => true
    #
    # @example
    #
    #   identifier = Nanoc::Identifier.from_string('/foo/bar.md')
    #   pattern = Nanoc::Pattern.from('/articles/*.html')
    #   identifier.match?(pattern)
    #   # => false
    def match?(pattern)
      Nanoc::Pattern.from(pattern).match?(to_s)
    end

    # @!group Inherited

    # @see Object#hash
    def hash
      components.hash
    end

    # @see Object#eql?
    def eql?(other)
      case other
      when Nanoc::Identifier
        components == other.components
      else
        to_s == other.to_s
      end
    end

    # @see Object#==
    def ==(other)
      self.eql?(other)
    end

    # @see Object#<=>
    def <=>(other)
      case other
      when Nanoc::Identifier
        components <=> other.components
      else
        to_s <=> other.to_s
      end
    end

    # @see Object#inspect
    def inspect
      "<#{self.class} #{to_s.inspect}>"
    end
  end
end
