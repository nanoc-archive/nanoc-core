# encoding: utf-8

module Nanoc::RuleMemoryActions

  class Write < Nanoc::RuleMemoryAction
    # write '/path.html'
    # write '/path.html', snapshot: :final

    attr_reader :path
    attr_reader :snapshot_name

    def initialize(path, snapshot_name)
      @path          = path
      @snapshot_name = snapshot_name
    end

    def snapshot?
      !@snapshot_name.nil?
    end

    def type
      :write
    end

    def serialize
      [ :write, @path, { snapshot: @snapshot_name } ]
    end

    def to_s
      s = "write #{@path.inspect}"

      if @snapshot_name
        s << ", snapshot: #{@snapshot_name.inspect}"
      end

      s
    end

    def inspect
      "<Nanoc::RuleMemoryActions::Write #{@path.inspect}, snapshot: #{@snapshot_name.inspect}>"
    end

  end

end
