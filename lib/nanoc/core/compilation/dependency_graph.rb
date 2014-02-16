# encoding: utf-8

module Nanoc

  class DependencyGraph

    def initialize(items, layouts, data, is_new)
      @items   = items
      @layouts = layouts

      # FIXME ew, work in the constructor
      if data
        @graph = unserialize(data)
      else
        @graph = Nanoc::DirectedGraph.new
      end

      # FIXME ew, work in the constructor
      if is_new
        add_all_vertices
      end
    end

    def add_all_vertices
      @items.each do |item|
        @graph.add_vertex(item.reference)
      end

      @layouts.each do |layout|
        @graph.add_vertex(layout.reference)
      end
    end

    def vertices
      @graph.vertices
    end

    def unserialize(data)
      graph = Nanoc::DirectedGraph.unserialize(data)

      # TODO none of this should really happen here
      # Ideally, the outdatedness checker should have a reference to both the
      # original and the current dependency graph. With these two graphs, it can
      # easily find out new and removed items.

      # Remove vertices no longer corresponding to objects
      removed_vertices = graph.vertices.select { |v| resolve(v).nil? }
      removed_vertices.each do |removed_vertex|
        graph.direct_predecessors_of(removed_vertex).each do |pred|
          graph.add_edge(pred, nil)
        end
        graph.delete_vertex(removed_vertex)
      end

      graph
    end

    def serialize
      @graph.serialize
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
    def objects_depended_on_by(object)
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
    def objects_depending_on(object)
      resolve_all(@graph.direct_predecessors_of(object.reference))
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

    protected

    def resolve_all(references)
      references.map { |r| resolve(r) }
    end

    def resolve(reference)
      return nil if reference.nil?

      case reference[0]
      when :item
        @items[reference[1]]
      when :layout
        @layouts.find { |l| l.identifier.to_s == reference[1] }
      else
        raise 'unknown reference type'
      end
    end

  end

end
