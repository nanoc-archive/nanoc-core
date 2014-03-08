# encoding: utf-8

module Nanoc

  # A wrapper around {Nanoc::Document} that provides restricted access. Document
  # views should be used in assigns when filtering and layouting.
  class DocumentView

    # @param [Nanoc::Document] wrapped
    def initialize(wrapped)
      @wrapped = wrapped
    end

    # @return [Nanoc::Document] the document this view is for
    #
    # @api private
    def resolve
      @wrapped
    end

    def inspect
      "<#{resolve.class.to_s}* identifier=#{resolve.identifier.to_s.inspect}>"
    end

    # Requests the attribute with the given key.
    #
    # @param [Symbol] key The name of the attribute to fetch
    #
    # @return The value of the requested attribute
    def [](key)
      Nanoc::NotificationCenter.post(:visit_started, resolve)
      Nanoc::NotificationCenter.post(:visit_ended,   resolve)

      resolve.attributes[key]
    end

    # @return [Nanoc::Identifier]
    def identifier
      resolve.identifier
    end

  end

end
