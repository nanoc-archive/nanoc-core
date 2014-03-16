# encoding: utf-8

module Nanoc::RuleMemoryActions

  class Snapshot < Nanoc::RuleMemoryAction
    # snapshot :before_layout
    # snapshot :before_layout, path: '/foo-snippet.html'
    # snapshot :before_layout, final: true

    attr_reader :snapshot_name
    attr_reader :path
    attr_reader :final
    alias_method :final?, :final

    def initialize(snapshot_name, path, final)
      @snapshot_name = snapshot_name
      @path          = path
      @final         = final
    end

    def serialize
      [ :snapshot, @snapshot_name, { path: @path, final: @final } ]
    end

    def to_s
      "snapshot #{@snapshot_name.inspect}, path: #{@path.inspect}, final: #{@final.inspect}"
    end

  end

end
