# encoding: utf-8

module Nanoc

  class DocumentView

    # @param [Nanoc::Document] wrapped
    def initialize(wrapped)
      @wrapped = wrapped
    end

    # @return [Nanoc::Document] the item this view is for
    #
    # @api private
    def resolve
      @wrapped
    end

    def inspect
      "<#{resolve.class.to_s}* identifier=#{resolve.identifier.to_s.inspect}>"
    end

    def [](key)
      Nanoc::NotificationCenter.post(:visit_started, resolve)
      Nanoc::NotificationCenter.post(:visit_ended,   resolve)

      resolve.attributes[key]
    end

    def identifier
      resolve.identifier
    end

  end

end
