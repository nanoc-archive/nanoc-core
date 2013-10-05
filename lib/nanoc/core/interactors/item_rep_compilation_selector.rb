# encoding: utf-8

module Nanoc

  class ItemRepCompilationSelector

    def initialize(reps)
      @reps = reps
    end

    # TODO it would be cool to have the previous graph of hard dependencies here
    # so that reps can be selected in a more intelligent manner

    def each(&block)
      content_dependency_graph = Nanoc::DirectedGraph.new(@reps)

      loop do
        # Find rep
        break if content_dependency_graph.roots.empty?
        rep = content_dependency_graph.roots.each { |e| break e }

        # Handle rep
        begin
          block.call(rep)
          content_dependency_graph.delete_vertex(rep)
        rescue Nanoc::Errors::UnmetDependency => e
          content_dependency_graph.add_edge(e.rep, rep)
          unless content_dependency_graph.vertices.include?(e.rep)
            content_dependency_graph.add_vertex(e.rep)
          end
        end
      end

      # Check whether everything was handled
      if !content_dependency_graph.vertices.empty?
        raise Nanoc::Errors::RecursiveCompilation.new(content_dependency_graph.vertices)
      end
    end

  end

end
