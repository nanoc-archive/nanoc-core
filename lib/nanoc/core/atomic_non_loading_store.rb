# encoding: utf-8

module Nanoc

  # An abstract superclass for classes that need to store data to the
  # filesystem, such as checksums, cached compiled content and dependency
  # graphs.
  #
  # Each store has a version number. When attempting to load data from a store
  # that has an incompatible version number, no data will be loaded, but
  # {#version_mismatch_detected} will be called.
  #
  # @abstract Subclasses must implement {#data} and {#data=}, and may
  #   implement {#no_data_found} and {#version_mismatch_detected}.
  #
  # @api private
  class AtomicNonLoadingStore

    # @return [String] The name of the file where data will be loaded from and
    #   stored to.
    attr_reader :filename

    # @return [Numeric] The version number corresponding to the file format
    #   the data is in. When the file format changes, the version number
    #   should be incremented.
    attr_reader :version

    # Creates a new store for the given filename.
    #
    # @param [String] filename The name of the file where data will be loaded
    #   from and stored to.
    #
    # @param [Numeric] version The version number corresponding to the file
    #   format the data is in. When the file format changes, the version
    #   number should be incremented.
    def initialize(filename, version)
      @filename = filename
      @version  = version
    end

    def load
      return if @loaded

      # Create starting copy
      FileUtils.mkdir_p(File.dirname(filename))
      if File.file?(filename)
        FileUtils.cp(filename, tmp_filename)
      else
        FileUtils.rm_f(tmp_filename)
      end

      # (Re)initialize if necessary
      @store = PStore.new(tmp_filename)
      @store.transaction do
        if !@store.root?(:version) || @store[:version] != version
          @store[:version] = version
          @store[:data]    = {}
        end
      end

      @loaded = true
    end

    def store
      FileUtils.mv(tmp_filename, filename)
    end

    def [](key)
      @store.transaction do
        @store[:data][key]
      end
    end

    def []=(key, value)
      @store.transaction do
        @store[:data][key] = value
      end
    end

    private

    def tmp_filename
      filename + '.tmp'
    end

  end

end
