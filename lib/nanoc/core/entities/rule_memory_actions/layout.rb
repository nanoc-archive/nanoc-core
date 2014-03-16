# encoding: utf-8

module Nanoc::RuleMemoryActions

  class Layout < Nanoc::RuleMemoryAction
    # layout '/foo.erb'
    # layout '/foo.erb', params

    def initialize(layout_name, params)
      @layout_name = layout_name
      @params      = params
    end

    def serialize
      [ :layout, @layout_name, @params ]
    end

    def to_s
      if @params
        "layout :#{@layout_name}, #{@params.inspect}"
      else
        "layout :#{@layout_name}"
      end
    end

    def inspect
      "<Nanoc::RuleMemoryActions::Layout #{@layout_name.inspect}, #{@params.inspect}>"
    end

  end

end
