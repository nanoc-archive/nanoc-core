# encoding: utf-8

module Nanoc
  module RuleMemoryActions
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

      def serialize
        [:write, @path, { snapshot: @snapshot_name }]
      end

      def to_s
        "write #{@path.inspect}, snapshot: #{@snapshot_name.inspect}"
      end

      def with_snapshot_name(snapshot_name)
        self.class.new(@path, snapshot_name)
      end
    end
  end
end
