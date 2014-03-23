# encoding: utf-8

module Nanoc

  # Loads sites.
  #
  # @api private
  class SiteLoader

    # The default configuration for a data source. A data source's
    # configuration overrides these options.
    DEFAULT_DATA_SOURCE_CONFIG = {
      type:            'filesystem',
      items_root:      '/',
      layouts_root:    '/',
      text_extensions: %w( css erb haml htm html js less markdown md php rb sass scss txt xhtml xml coffee hb handlebars mustache ms slim ).sort,
      content_dir:     'content',
      layouts_dir:     'layouts',
    }

    # The default configuration for a site. A site's configuration overrides
    # these options: when a {Nanoc::Site} is created with a configuration
    # that lacks some options, the default value will be taken from
    # `DEFAULT_CONFIG`.
    DEFAULT_CONFIG = {
      build_dir:          'build',
      data_sources:       [ {} ],
      index_filenames:    [ 'index.html' ],
      enable_output_diff: false,
      prune:              { auto_prune: true, exclude: [ '.git', '.hg', '.svn', 'CVS' ] },
    }

    CONFIG_FILENAME = 'nanoc.yaml'

    # @return [Nanoc::Site] A new site based on the current working directory
    def load
      # Load
      config
      code_snippets
      data_sources
      data_sources.each { |ds| ds.use }
      items
      layouts
      data_sources.each { |ds| ds.unuse }

      # Build site
      Nanoc::Site.new({
        data_sources:  data_sources,
        items:         items,
        layouts:       layouts,
        code_snippets: code_snippets,
        config:        config,
      })
    end

    # @return [Boolean] true if the current working directory is a nanoc site, false otherwise
    #
    # @api private
    def self.cwd_is_nanoc_site?
      File.file?(CONFIG_FILENAME)
    end

  protected

    # Returns the data sources for this site. Will create a new data source if
    # none exists yet.
    #
    # @return [Array<Nanoc::DataSource>] The list of data sources for this
    #   site
    #
    # @raise [Nanoc::Errors::UnknownDataSource] if the site configuration
    #   specifies an unknown data source
    def data_sources
      @data_sources ||= begin
        config[:data_sources].map do |data_source_hash|
          # Get data source class
          data_source_class = Nanoc::DataSource.named(data_source_hash[:type].to_sym)
          raise Nanoc::Errors::UnknownDataSource.new(data_source_hash[:type]) if data_source_class.nil?

          # Create data source
          data_source_class.new(
            data_source_hash[:items_root],
            data_source_hash[:layouts_root],
            data_source_hash.merge(data_source_hash[:config] || {})
          )
        end
      end
    end

    def code_snippets
      @_code_snippets ||= begin
        Dir['lib/**/*.rb'].sort.map do |filename|
          Nanoc::CodeSnippet.new(
            File.read(filename),
            filename
          ).tap { | cs| cs.load }
        end
      end
    end

    def items
      @_items ||= begin
        array = Nanoc::ItemCollection.new
        data_sources.each do |ds|
          items_in_ds = ds.items
          items_in_ds.each do |i|
            i.identifier = i.identifier.prefix(ds.items_root)
            i.site = self
          end
          array.concat(items_in_ds)
        end
        array
      end
    end

    def layouts
      @_layouts ||= begin
        data_sources.flat_map do |ds|
          layouts_in_ds = ds.layouts
          layouts_in_ds.each do |i|
            i.identifier = i.identifier.prefix(ds.layouts_root)
          end
        end
      end
    end

    def config
      @_config ||= begin
        # Find config file
        unless self.class.cwd_is_nanoc_site?
          raise Nanoc::Errors::GenericTrivial,
            "Could not find #{CONFIG_FILENAME} in the current working directory"
        end

        # Load
        config = YAML.load_file(CONFIG_FILENAME).symbolize_keys_recursively
        config = DEFAULT_CONFIG.merge(config)
        config[:data_sources] = config[:data_sources].map do |dsc|
          DEFAULT_DATA_SOURCE_CONFIG.merge(dsc)
        end

        # Convert to proper configuration
        Nanoc::Configuration.new(config)
      end
    end

  end

end
