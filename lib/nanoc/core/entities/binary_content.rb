# encoding: utf-8

require 'nanoc/core/entities/content'

module Nanoc

  class BinaryContent < Content

    def binary?
      true
    end

    def checksum
      stat = File.stat(@filename)
      stat.size.to_s + '-' + stat.mtime.to_s
    end

    def inspect
      "<#{self.class} filename=\"#{self.filename}\">"
    end

  end

end
