# encoding: utf-8

module Nanoc

  class RuleMemoryAction

    def serialize
      raise NotImplementedError.new('Nanoc::RuleMemoryAction subclasses must implement #serialize, #to_s and #inspect')
    end

    def to_s
      raise NotImplementedError.new('Nanoc::RuleMemoryAction subclasses must implement #serialize, #to_s and #inspect')
    end

    def inspect
      raise NotImplementedError.new('Nanoc::RuleMemoryAction subclasses must implement #serialize, #to_s and #inspect')
    end

  end

end
