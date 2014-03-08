# encoding: utf-8

module Nanoc

  class LayoutView

    extend Forwardable
    extend Nanoc::Memoization

    # TODO do not delegate #[] (do dependency tracking in view)
    def_delegators :@layout, :identifier, :[]

    # @param [Nanoc::Layout] layout
    def initialize(layout)
      @layout = layout
    end

    # @return [Nanoc::Layout] the item this view is for
    #
    # @api private
    def resolve
      @layout
    end

    def inspect
      "<Nanoc::Layout* identifier=#{@layout.identifier.to_s.inspect}>"
    end

  end

end
