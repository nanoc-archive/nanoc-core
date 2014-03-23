# encoding: utf-8

module Nanoc

  # Responsible for finding and deleting files in the site’s output directory
  # that are not managed by nanoc.
  class Pruner

    extend DDPlugin::Plugin

    # @return [Nanoc::Site] The site this pruner belongs to
    attr_reader :site

    # @param [Nanoc::Site] site The site for which a pruner is created
    #
    # @option params [Boolean] :dry_run (false) true if the files to be deleted
    #   should only be printed instead of actually deleted, false if the files
    #   should actually be deleted.
    def initialize(site, params = {})
      @site    = site
      @dry_run = params.fetch(:dry_run, false)
      @exclude = params.fetch(:exclude, [])
    end

    # Prunes all output files not managed by nanoc.
    #
    # @return [void]
    def run
      raise NotImplementedError
    end

  end

  class FilesystemPruner < Pruner

    identifier :filesystem

    def find_compiled_files
      compiler = Nanoc::CompilerBuilder.new.build(site)
      writer = compiler.item_rep_writer

      compiler.item_rep_store.reps.
        flat_map { |r| r.written_paths }.
        select { |f| writer.exist?(f) }.
        map { |f| writer.full_path_for(f) }
    end

    def find_present_files_and_dirs
      present_files = []
      present_dirs = []

      Find.find(site.config[:build_dir] + '/') do |f|
        present_files << f if File.file?(f)
        present_dirs  << f if File.directory?(f)
      end

      [ present_files, present_dirs ]
    end

    # @see Nanoc::Pruner#run
    def run
      require 'find'

      # Get compiled files
      compiled_files = find_compiled_files

      # Get present files and dirs
      present_files, present_dirs = find_present_files_and_dirs

      # Remove stray files
      stray_files = (present_files - compiled_files)
      stray_files.each do |f|
        next if filename_excluded?(f)
        delete_file(f)
      end

      # Remove empty directories
      present_dirs.reverse_each do |dir|
        next if Dir.foreach(dir) { |n| break true if n !~ /\A\.\.?\z/ }
        next if filename_excluded?(dir)
        delete_dir(dir)
      end
    end

    # @param [String] filename The filename to check
    #
    # @return [Boolean] true if the given file is excluded, false otherwise
    def filename_excluded?(filename)
      pathname = Pathname.new(filename)
      @exclude.any? { |e| components_for_pathname(pathname).include?(e) }
    end

    protected

    def delete_file(file)
      if @dry_run
        puts file
      else
        # TODO log file deletion
        FileUtils.rm(file)
      end
    end

    def delete_dir(dir)
      if @dry_run
        puts dir
      else
        # TODO log file deletion
        Dir.rmdir(dir)
      end
    end

    def components_for_pathname(pathname)
      components = []
      tmp = pathname
      loop do
        old = tmp
        components << File.basename(tmp)
        tmp = File.dirname(tmp)
        break if old == tmp
      end
      components.reverse
    end

  end

end
