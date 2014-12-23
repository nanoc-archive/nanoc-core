# encoding: utf-8

require 'nanoc/core/entities/content'

module Nanoc
  class BinaryContent < Content
    def binary?
      true
    end

    def inspect
      "<#{self.class} filename=\"#{filename}\">"
    end
  end
end
