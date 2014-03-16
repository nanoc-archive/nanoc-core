# encoding: utf-8

module Nanoc::RuleMemoryActions

  class Filter < Nanoc::RuleMemoryAction
    # filter :foo
    # filter :foo, params

    def initialize(filter_name, params)
      @filter_name = filter_name
      @params      = params
    end

    def type
      :filter
    end

    def serialize
      [ :filter, @filter_name, @params ]
    end

    def to_s
      if @params
        "filter :#{@filter_name}, #{@params.inspect}"
      else
        "filter :#{@filter_name}"
      end
    end

    def inspect
      "<Nanoc::RuleMemoryActions::Filter #{@filter_name.inspect}, #{@params.inspect}>"
    end

  end

end
