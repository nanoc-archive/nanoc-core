# encoding: utf-8

module Nanoc

  # Responsible for remembering dependencies between items and layouts. It is
  # used to speed up compilation by only letting an item be recompiled when it
  # is outdated or any of its dependencies (or dependencies’ dependencies,
  # etc) is outdated.
  #
  # The dependencies tracked by the dependency tracker are not dependencies
  # based on an item’s or a layout’s content. When one object uses an
  # attribute of another object, then this is also treated as a dependency.
  # While dependencies based on an item’s or layout’s content (handled in
  # {Nanoc::Compiler}) cannot be mutually recursive, the more general
  # dependencies in Nanoc::DependencyTracker can (e.g. item A can use an
  # attribute of item B and vice versa without problems).
  #
  # The dependency tracker remembers the dependency information between runs.
  # Dependency information is stored in the `tmp/dependencies` file.
  #
  # @api private
  #
  # TODO split out some stuff into a DependencyGraph class
  class DependencyTracker < ::Nanoc::Store

    # Creates a new dependency tracker for the given items and layouts.
    #
    # @param [Array<Nanoc::Item, Nanoc::Layout>] objects The list of items
    #   and layouts whose dependencies should be managed
    def initialize(item_collection, layouts)
      super('tmp/dependencies', 5)

      @item_collection = item_collection
      @layouts = layouts
      @dependency_graph = Nanoc::DependencyGraph.new(@item_collection, @layouts, nil)
      @stack   = []
    end

    # Starts listening for dependency messages (`:visit_started` and
    # `:visit_ended`) and start recording dependencies.
    #
    # @return [void]
    def start
      # Initialize dependency stack. An object will be pushed onto this stack
      # when it is visited. Therefore, an object on the stack always depends
      # on all objects pushed above it.
      @stack = []

      # Register start of visits
      Nanoc::NotificationCenter.on(:visit_started, self) do |obj|
        if obj.is_a?(Nanoc::ItemView)
          raise 'Cannot depend on item views'
        end

        if !@stack.empty?
          Nanoc::NotificationCenter.post(:dependency_created, @stack.last, obj)
          record_dependency(@stack.last, obj)
        end
        @stack.push(obj)
      end

      # Register end of visits
      Nanoc::NotificationCenter.on(:visit_ended, self) do |obj|
        @stack.pop
      end
    end

    # Stop listening for dependency messages and stop recording dependencies.
    #
    # @return [void]
    def stop
      # Sanity check
      if !@stack.empty?
        raise "Internal inconsistency: dependency tracker stack not empty at end of compilation"
      end

      # Unregister
      Nanoc::NotificationCenter.remove(:visit_started, self)
      Nanoc::NotificationCenter.remove(:visit_ended,   self)
    end

    # @return The topmost item on the stack, i.e. the one currently being
    #   compiled
    #
    # @api private
    def top
      @stack.last
    end

    # @see Nanoc::DependencyGraph#objects_depended_on_by
    def objects_depended_on_by(object)
      @dependency_graph.objects_depended_on_by(object)
    end

    # @see Nanoc::DependencyGraph#objects_depending_on
    def objects_depending_on(object)
      @dependency_graph.objects_depending_on(object)
    end

    # @see Nanoc::DependencyGraph#record_dependency
    def record_dependency(src, dst)
      @dependency_graph.record_dependency(src, dst)
    end

    # @see Nanoc::DependencyGraph#forget_dependencies_for
    def forget_dependencies_for(object)
      @dependency_graph.forget_dependencies_for(object)
    end

    # @see Nanoc::Store#unload
    def unload
    end

    protected

    def data
      @dependency_graph.serialize
    end

    def data=(new_data)
      @dependency_graph = Nanoc::DependencyGraph.new(
        @item_collection, @layouts, new_data)
    end

  end

end
