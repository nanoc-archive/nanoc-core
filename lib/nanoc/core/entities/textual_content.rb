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

    def checksum
      digest = Digest::SHA1.new
      digest.update(@string)
      digest.hexdigest
    end

    def inspect
      "<#{self.class} filename=\"#{self.filename}\" string=\"#{self.string}\">"
    end

    def marshal_dump
      [ @string ]
    end

    def marshal_load(source)
      @string, _ = *source
    end

  end

end
