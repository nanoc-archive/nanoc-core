# encoding: utf-8

module Nanoc

  # Represents the site configuration.
  class Configuration

    attr_reader :wrapped

    # Creates a new configuration with the given hash.
    #
    # @param [Hash] wrapped The actual configuration hash
    def initialize(wrapped)
      @wrapped = wrapped
    end

    # @see Hash#[]
    def [](key)
      @wrapped[key]
    end

    # @see Hash#fetch
    def fetch(key, value)
      @wrapped.fetch(key, value)
    end

    # @see Hash#[]=
    def []=(key, value)
      @wrapped[key] = value
    end

    # @see Hash#freeze_recursively
    def freeze_recursively
      freeze
      @wrapped.freeze_recursively
    end

    # Returns an object that can be used for uniquely identifying objects.
    #
    # @return [Object] An unique reference to this object
    def reference
      :config
    end

  end

end
