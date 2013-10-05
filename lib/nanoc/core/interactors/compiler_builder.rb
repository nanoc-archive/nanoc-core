# encoding: utf-8

module Nanoc

  # Generates compilers.
  #
  # @api private
  class CompilerBuilder

    def initialize(site)
      @site = site
    end

    def build
      dependency_tracker = self.build_dependency_tracker

      Nanoc::Compiler.new(
        @site,
        dependency_tracker: dependency_tracker)
    end

    protected

    def build_dependency_tracker
      Nanoc::DependencyTracker.new(@site.items + @site.layouts)
    end

  end

end
