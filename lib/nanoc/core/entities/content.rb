# encoding: utf-8

module Nanoc

  class Content

    attr_reader :filename

    def initialize(filename)
      validate_filename(filename)

      @filename = filename
    end

    def binary?
      raise NotImplementedError
    end

    def checksum
      raise NotImplementedError
    end

    protected

    def validate_filename(filename)
      if filename && !filename.start_with?('/')
        raise ArgumentError, "Filename should be absolute (got #{filename})"
      end
    end

  end

end
