# encoding: utf-8

require 'nanoc/core/entities/content'

module Nanoc

  class TextualContent < Content

    attr_reader :string

    def initialize(string, filename)
      super(filename)
      @string = string
    end

    def binary?
      false
    end

    def inspect
      "<#{self.class} filename=\"#{filename}\" string=\"#{string}\">"
    end

  end

end
