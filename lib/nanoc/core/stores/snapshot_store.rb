# encoding: utf-8

module Nanoc

  # Stores compiled item rep snapshots.
  class SnapshotStore

    extend DDPlugin::Plugin

    # Fetches the content for the given snapshot.
    #
    # @param [String] item_identifier The identifier of the item
    #
    # @param [Symbol] rep_name The name of the item representation
    #
    # @param [Symbol] snapshot_name The name of the snapshot
    #
    # @return [String] The snapshot content
    def query(item_identifier, rep_name, snapshot_name)
    end

    # Sets the content for the given snapshot.
    #
    # @param [String] item_identifier The identifier of the item
    #
    # @param [Symbol] rep_name The name of the item representation
    #
    # @param [Symbol] snapshot_name The name of the snapshot
    #
    # @return [void]
    def set(item_identifier, rep_name, snapshot_name, content)
    end

    # @param [String] item_identifier The identifier of the item
    #
    # @param [Symbol] rep_name The name of the item representation
    #
    # @param [Symbol] snapshot_name The name of the snapshot
    #
    # @return [Boolean] true if content for the given snapshot exists, false otherwise
    def exist?(item_identifier, rep_name, snapshot_name)
    end

    # A snapshot store that keeps content in memory as Ruby objects.
    class InMemory < Nanoc::SnapshotStore

      identifier :in_memory

      def initialize
        @store = {}
      end

      def query(item_identifier, rep_name, snapshot_name)
        item_identifier = Nanoc::Identifier.coerce(item_identifier)
        key = [ item_identifier.to_s, rep_name, snapshot_name ]
        @store.fetch(key)
      end

      def set(item_identifier, rep_name, snapshot_name, content)
        item_identifier = Nanoc::Identifier.coerce(item_identifier)
        key = [ item_identifier.to_s, rep_name, snapshot_name ]
        content.freeze
        @store[key] = content
      end

      def exist?(item_identifier, rep_name, snapshot_name)
        item_identifier = Nanoc::Identifier.coerce(item_identifier)
        key = [ item_identifier.to_s, rep_name, snapshot_name ]
        @store.has_key?(key)
      end

    end

  end

end
