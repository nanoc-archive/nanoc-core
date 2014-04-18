# encoding: utf-8

module Nanoc

  # TODO document
  class Checksummer

    # TODO document
    class UnchecksummableError < Nanoc::Errors::Generic

      def initialize(obj)
        @obj = obj
      end

      def message
        "Don’t know how to create checksum for a #{obj.class}"
      end

    end

    # TODO document
    def self.instance
      @_instance ||= self.new
    end

    # TODO document
    def self.calc(obj)
      instance.calc(obj)
    end

    # TODO document
    def calc(obj)
      case obj
      when String
        digest = Digest::SHA1.new
        digest.update(obj)
        digest.hexdigest
        # TODO don’t need hexdigest per se
      when Array, Hash
        calc_dump_or_inspect(obj)
      when BinaryContent
        stat = File.stat(obj.filename)
        calc(stat.size.to_s + '-' + stat.mtime.to_s)
      when TextualContent
        calc(obj.string)
      when CodeSnippet
        calc(obj.data)
      when Configuration
        calc(obj.wrapped)
      when Document
        calc([obj.content, obj.attributes])
      else
        raise UnchecksummableError.new(obj)
      end
    end

    private

    def calc_dump_or_inspect(obj)
      calc(Marshal.dump(obj))
    rescue
      calc(obj.inspect)
    end

  end

end
