# encoding: utf-8

module Nanoc

  # Responsible for compiling a site’s item representations.
  #
  # The compilation process makes use of notifications (see
  # {Nanoc::NotificationCenter}) to track dependencies between items,
  # layouts, etc. The following notifications are used:
  #
  # * `compilation_started` — indicates that the compiler has started
  #   compiling this item representation. Has one argument: the item
  #   representation itself. Only one item can be compiled at a given moment;
  #   therefore, it is not possible to get two consecutive
  #   `compilation_started` notifications without also getting a
  #   `compilation_ended` notification in between them.
  #
  # * `compilation_ended` — indicates that the compiler has finished compiling
  #   this item representation (either successfully or with failure). Has one
  #   argument: the item representation itself.
  #
  # * `visit_started` — indicates that the compiler requires content or
  #   attributes from the item representation that will be visited. Has one
  #   argument: the visited item identifier. This notification is used to
  #   track dependencies of items on other items; a `visit_started` event
  #   followed by another `visit_started` event indicates that the item
  #   corresponding to the former event will depend on the item from the
  #   latter event.
  #
  # * `visit_ended` — indicates that the compiler has finished visiting the
  #   item representation and that the requested attributes or content have
  #   been fetched (either successfully or with failure)
  class Compiler

    # @group Accessors

    # @return [Nanoc::Site] The site this compiler belongs to
    attr_reader :site

    # FIXME ugly
    attr_reader :item_rep_store
    attr_reader :item_rep_writer
    attr_reader :outdatedness_checker
    attr_reader :dependency_tracker

    # @group Public instance methods

    # Creates a new compiler for the given site
    #
    # @param [Nanoc::Site] site The site this compiler belongs to
    #
    # TODO document dependencies
    def initialize(site, dependencies)
      @site = site
      @dependency_tracker     = dependencies.fetch(:dependency_tracker)
      @rules_store            = dependencies.fetch(:rules_store)
      @checksum_store         = dependencies.fetch(:checksum_store)
      @compiled_content_cache = dependencies.fetch(:compiled_content_cache)
      @rule_memory_store      = dependencies.fetch(:rule_memory_store)
      @item_rep_writer        = dependencies.fetch(:item_rep_writer)
      @rule_memory_calculator = dependencies.fetch(:rule_memory_calculator)
      @item_rep_store         = dependencies.fetch(:item_rep_store)
      @outdatedness_checker   = dependencies.fetch(:outdatedness_checker)
      @preprocessor           = dependencies.fetch(:preprocessor)
    end

    # Compiles the site and writes out the compiled item representations.
    #
    def run
      @preprocessor.run
      @dependency_tracker.start
      compile_reps(self.item_rep_store.reps)
      @dependency_tracker.stop
      store
      prune
    ensure
      # Cleanup
      FileUtils.rm_rf(Nanoc::Filter::TMP_BINARY_ITEMS_DIR)
      FileUtils.rm_rf(Nanoc::FilesystemItemRepWriter::TMP_TEXT_ITEMS_DIR)
    end

    # @group Private instance methods

    # Store the modified helper data used for compiling the site.
    #
    # @api private
    #
    # @return [void]
    def store
      # Calculate rule memory
      (self.item_rep_store.reps + @site.layouts).each do |obj|
        @rule_memory_store[obj] = @rule_memory_calculator[obj]
      end

      # Calculate checksums
      (site.items.to_a + site.layouts + site.code_snippets + [ site.config ]).each do |obj|
        @checksum_store[obj] = obj.checksum
      end
      @checksum_store[self.rules_collection] = @rules_store.rule_data

      # Store
      @checksum_store.store
      @compiled_content_cache.store
      @dependency_tracker.store
      @rule_memory_store.store
    end

    def write_rep(rep, path)
      @item_rep_writer.write(rep, path.to_s)
    end

    # @param [Nanoc::ItemRep] rep The item representation for which the
    #   assigns should be fetched
    #
    # @return [Hash] The assigns that should be used in the next filter/layout
    #   operation
    #
    # @api private
    def assigns_for(rep)
      if rep.snapshot_binary?(:last)
        content_or_filename_assigns = { :filename => rep.temporary_filenames[:last] }
      else
        content_or_filename_assigns = { :content => rep.stored_content_at_snapshot(:last) }
      end

      content_or_filename_assigns.merge({
        :item       => Nanoc::ItemView.new(rep.item, self.item_rep_store),
        :rep        => Nanoc::ItemRepViewForFiltering.new(rep, self.item_rep_store),
        :item_rep   => Nanoc::ItemRepViewForFiltering.new(rep, self.item_rep_store),
        :items      => site.items.wrapped(-> (i) { Nanoc::ItemView.new(i, self.item_rep_store) }),
        :layouts    => site.layouts,
        :config     => site.config,
        :site       => site,
        :_compiler  => self
      })
    end

    def rules_collection
      @rules_store.rules_collection
    end

  protected

    # Compiles the given representations.
    #
    # @param [Array] reps The item representations to compile.
    #
    # @return [void]
    def compile_reps(reps)
      # Assign snapshots
      reps.each do |rep|
        rep.snapshots = @rule_memory_calculator.snapshots_for(rep)
      end

      # Compile
      Nanoc::ItemRepCompilationSelector.new(reps).each do |rep|
        compile_rep(rep)
        # TODO call store here for incremental compilation support
      end
    end

    # Compiles the given item representation.
    #
    # This method should not be called directly; please use
    # {Nanoc::Compiler#run} instead, and pass this item representation's item
    # as its first argument.
    #
    # @param [Nanoc::ItemRep] rep The rep that is to be compiled
    #
    # @return [void]
    def compile_rep(rep)
      Nanoc::NotificationCenter.post(:compilation_started, rep)
      Nanoc::NotificationCenter.post(:visit_started,       rep.item)

      if self.can_use_cache?(rep)
        fill_rep_from_cache(rep)
      else
        fill_rep_by_recompiling(rep)
      end

      rep.compiled = true

      Nanoc::NotificationCenter.post(:compilation_ended, rep)
    rescue => e
      rep.forget_progress
      Nanoc::NotificationCenter.post(:compilation_failed, rep, e)
      raise e
    ensure
      Nanoc::NotificationCenter.post(:visit_ended,       rep.item)
    end

    def can_use_cache?(rep)
      !rep.item.forced_outdated? &&
        !@outdatedness_checker.outdated?(rep) &&
        @compiled_content_cache[rep]
    end

    def fill_rep_from_cache(rep)
      Nanoc::NotificationCenter.post(:cached_content_used, rep)
      rep.content = @compiled_content_cache[rep]
    end

    def fill_rep_by_recompiling(rep)
      @dependency_tracker.forget_dependencies_for(rep.item)
      rep_view = Nanoc::ItemRepViewForRuleProcessing.new(rep, self)
      rules_collection.compilation_rule_for(rep).apply_to(rep_view, site)
      rep.snapshot(:last)
      @compiled_content_cache[rep] = rep.content
    end

    def prune
      if self.site.config[:prune][:auto_prune]
        identifier = @item_rep_writer.class.identifier
        pruner_class = Nanoc::Pruner.named(identifier)
        exclude = self.site.config.fetch(:prune, {}).fetch(:exclude, [])
        pruner_class.new(self.site, :exclude => exclude).run
      end
    end

  end

end
