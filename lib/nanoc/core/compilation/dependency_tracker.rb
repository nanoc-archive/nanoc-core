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
      super('tmp/dependencies', 4)

      @item_collection = item_collection
      @layouts = layouts

      @graph   = Nanoc::DirectedGraph.new
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

    # Returns the direct dependencies for the given object.
    #
    # The direct dependencies of the given object include the items and
    # layouts that, when outdated will cause the given object to be marked as
    # outdated. Indirect dependencies will not be returned (e.g. if A depends
    # on B which depends on C, then the direct dependencies of A do not
    # include C).
    #
    # The direct predecessors can include nil, which indicates an item that is
    # no longer present in the site.
    #
    # @param [Nanoc::Item, Nanoc::Layout] object The object for
    #   which to fetch the direct predecessors
    #
    # @return [Array<Nanoc::Item, Nanoc::Layout, nil>] The direct
    # predecessors of
    #   the given object
    def objects_causing_outdatedness_of(object)
      resolve_all(@graph.direct_successors_of(object.reference))
    end

    # Returns the direct inverse dependencies for the given object.
    #
    # The direct inverse dependencies of the given object include the objects
    # that will be marked as outdated when the given object is outdated.
    # Indirect dependencies will not be returned (e.g. if A depends on B which
    # depends on C, then the direct inverse dependencies of C do not include
    # A).
    #
    # @param [Nanoc::Item, Nanoc::Layout] object The object for which to
    #   fetch the direct successors
    #
    # @return [Array<Nanoc::Item, Nanoc::Layout>] The direct successors of
    #   the given object
    def objects_outdated_due_to(object)
      resolve_all(@graph.direct_predecessors_of(object.reference).compact)
    end

    # Records a dependency from `src` to `dst` in the dependency graph. When
    # `dst` is oudated, `src` will also become outdated.
    #
    # @param [Nanoc::Item, Nanoc::Layout] src The source of the dependency,
    #   i.e. the object that will become outdated if dst is outdated
    #
    # @param [Nanoc::Item, Nanoc::Layout] dst The destination of the
    #   dependency, i.e. the object that will cause the source to become
    #   outdated if the destination is outdated
    #
    # @return [void]
    def record_dependency(src, dst)
      return if src == dst || src.nil? || dst.nil?
      @graph.add_edge(src.reference, dst.reference)
      nil
    end

    # Empties the list of dependencies for the given object. This is necessary
    # before recompiling the given object, because otherwise old dependencies
    # will stick around and new dependencies will appear twice. This function
    # removes all incoming edges for the given vertex.
    #
    # @api private
    #
    # @param [Nanoc::Item, Nanoc::Layout] object The object for which to
    #   forget all dependencies
    #
    # @return [void]
    def forget_dependencies_for(object)
      @graph.delete_edges_from(object.reference)
      nil
    end

    # @see Nanoc::Store#unload
    def unload
      @graph = Nanoc::DirectedGraph.new
    end

    protected

    def resolve_all(references)
      references.map { |r| resolve(r) }
    end

    def resolve(reference)
      return nil if reference.nil?

      case reference[0]
      when :item
        @item_collection[reference[1]]
      when :layout
        @layouts.find { |l| l.identifier.to_s == reference[1] }
      else
        raise 'unknown reference type'
      end
    end

    def data
      @item_collection.each do |item|
        @graph.add_vertex(item.reference)
      end

      @layouts.each do |layout|
        @graph.add_vertex(layout.reference)
      end

      @graph.serialize
    end

    def data=(new_data)
      @graph = Nanoc::DirectedGraph.unserialize(new_data)

      # Let all items depend on new items
      new_items = @item_collection.select do |item|
        !@graph.vertex?(item.reference)
      end
      new_items.each do |new_item|
        @graph.vertices.each do |vertex|
          @graph.add_edge(vertex, new_item.reference)
        end
      end

      # Remove vertices no longer corresponding to objects
      removed_vertices = @graph.vertices.select { |v| resolve(v).nil? }
      # STDOUT.puts removed_vertices.inspect if $LOUD
      removed_vertices.each do |removed_vertex|
        @graph.direct_predecessors_of(removed_vertex).each do |pred|
          @graph.add_edge(pred, nil)
        end
        @graph.delete_vertex(removed_vertex)
      end

    end

  end

end
