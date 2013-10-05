# encoding: utf-8

module Nanoc

  class Preprocessor

    def initialize(site, rules_collection)
      @site             = site
      @rules_collection = rules_collection
    end

    def run
      if proc = @rules_collection.preprocessor
        new_preprocessor_context.instance_eval(&proc)
      end
    end

    protected

    def new_preprocessor_context
      Nanoc::Context.new({
        :site    => @site,
        :config  => @site.config,
        :items   => @site.items,
        :layouts => @site.layouts
      })
    end

  end

end
