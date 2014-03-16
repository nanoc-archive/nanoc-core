# encoding: utf-8

module Nanoc

  class RuleMemoryAction

    def type
      raise NotImplementedError.new('Nanoc::RuleMemoryAction subclasses must implement #type, #serialize and #to_s')
    end

    def serialize
      raise NotImplementedError.new('Nanoc::RuleMemoryAction subclasses must implement #type, #serialize and #to_s')
    end

    def to_s
      raise NotImplementedError.new('Nanoc::RuleMemoryAction subclasses must implement #type, #serialize and #to_s')
    end

  end

end
