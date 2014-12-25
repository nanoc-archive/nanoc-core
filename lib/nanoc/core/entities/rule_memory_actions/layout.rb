# encoding: utf-8

module Nanoc
  module RuleMemoryActions
    class Layout < Nanoc::RuleMemoryAction
      # layout '/foo.erb'
      # layout '/foo.erb', params

      def initialize(layout_name, params)
        @layout_name = layout_name
        @params      = params
      end

      def serialize
        [:layout, @layout_name, @params]
      end

      def to_s
        "layout #{@layout_name.inspect}, #{@params.inspect}"
      end
    end
  end
end
