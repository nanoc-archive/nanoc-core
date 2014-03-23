# encoding: utf-8

class Nanoc::ItemRepTest < Nanoc::TestCase

  class TextualFilter < ::Nanoc::Filter
    identifier :text_filter
    type :text
  end

  class BinaryFilter < ::Nanoc::Filter
    identifier :binary_filter
    type :binary
  end

  def new_item
    item = Nanoc::Item.new(
      Nanoc::TextualContent.new('blah blah blah', File.absolute_path('content/somefile.md')),
      {},
      '/stuff.md')
  end

  def new_snapshot_store
    Nanoc::SnapshotStore::InMemory.new
  end

  def test_created_modified_compiled
    # TODO implement
  end

  def test_compiled_content_with_only_last_available
    # Create rep
    item = new_item
    snapshot_store = new_snapshot_store
    rep = Nanoc::ItemRep.new(item, :foo, snapshot_store: snapshot_store, config: Nanoc::Configuration.new({}))
    snapshot_store.set('/stuff.md', :foo, :last, 'last content')
    rep.expects(:compiled?).returns(true)

    # Check
    assert_equal 'last content', rep.compiled_content
  end

  def test_compiled_content_with_pre_and_last_available
    # Create rep
    item = new_item
    snapshot_store = new_snapshot_store
    rep = Nanoc::ItemRep.new(item, :foo, snapshot_store: snapshot_store, config: Nanoc::Configuration.new({}))
    snapshot_store.set('/stuff.md', :foo, :pre,  'pre content')
    snapshot_store.set('/stuff.md', :foo, :last, 'last content')
    rep.expects(:compiled?).returns(true)

    # Check
    assert_equal 'last content', rep.compiled_content
  end

  def test_compiled_content_with_custom_snapshot
    # Create rep
    item = new_item
    snapshot_store = new_snapshot_store
    rep = Nanoc::ItemRep.new(item, :foo, snapshot_store: snapshot_store, config: Nanoc::Configuration.new({}))
    snapshot_store.set('/stuff.md', :foo, :pre,  'pre content')
    snapshot_store.set('/stuff.md', :foo, :last, 'last content')
    rep.expects(:compiled?).returns(true)

    # Check
    assert_equal 'last content', rep.compiled_content(snapshot: :last)
  end

  def test_compiled_content_with_invalid_snapshot
    # Create rep
    item = new_item
    snapshot_store = new_snapshot_store
    rep = Nanoc::ItemRep.new(item, :foo, snapshot_store: snapshot_store, config: Nanoc::Configuration.new({}))
    snapshot_store.set('/stuff.md', :foo, :pre,  'pre content')
    snapshot_store.set('/stuff.md', :foo, :last, 'last content')

    # Check
    assert_raises Nanoc::Errors::NoSuchSnapshot do
      rep.compiled_content(snapshot: :klsjflkasdfl)
    end
  end

  def test_compiled_content_with_uncompiled_content
    # Create rep
    item = new_item
    rep = Nanoc::ItemRep.new(item, :foo, snapshot_store: new_snapshot_store, config: Nanoc::Configuration.new({}))
    rep.expects(:compiled?).returns(false)

    # Check
    assert_raises(Nanoc::Errors::UnmetDependency) do
      rep.compiled_content
    end
  end

  def test_filter
    # Mock site
    site = MiniTest::Mock.new
    site.expect(:items, [])
    site.expect(:config, [])
    site.expect(:layouts, [])

    # Mock item
    item = Nanoc::Item.new(%(<%= '<%= "blah" %' + '>' %>), {}, '/test.md')

    # Create item rep
    snapshot_store = new_snapshot_store
    item_rep = Nanoc::ItemRep.new(item, :foo, snapshot_store: snapshot_store, config: Nanoc::Configuration.new({}))
    snapshot_store.set('/stuff.md', :foo, :raw,  item.content.string)
    snapshot_store.set('/stuff.md', :foo, :last, item.content.string)

    # Filter once
    item_rep.filter(:erb, {}, {})
    assert_equal(%(<%= "blah" %>), snapshot_store.query('/test.md', :foo, :last))

    # Filter twice
    item_rep.filter(:erb, {}, {})
    assert_equal(%(blah), snapshot_store.query('/test.md', :foo, :last))
  end

  def test_layout
    # Mock layout
    layout = Nanoc::Layout.new(%(<%= "blah" %>), {}, '/somelayout.erb')

    # Mock item
    item = Nanoc::Item.new(
      'blah blah', {}, '/blah.md',
    )

    # Create item rep
    snapshot_store = new_snapshot_store
    item_rep = Nanoc::ItemRep.new(item, :foo, snapshot_store: snapshot_store, config: Nanoc::Configuration.new({}))
    snapshot_store.set('/stuff.md', :foo, :raw,  item.content.string)
    snapshot_store.set('/stuff.md', :foo, :last, item.content.string)

    # Layout
    item_rep.layout(layout, :erb, {}, {})
    assert_equal(%(blah), snapshot_store.query('/blah.md', :foo, :last))
  end

  def test_snapshot
    # Mock site
    site = MiniTest::Mock.new
    site.expect(:items, [])
    site.expect(:config, [])
    site.expect(:layouts, [])

    # Mock item
    item = Nanoc::Item.new(
      %(<%= '<%= "blah" %' + '>' %>), {}, '/foobar.md',
    )

    # Create item rep
    snapshot_store = new_snapshot_store
    item_rep = Nanoc::ItemRep.new(item, :foo, snapshot_store: snapshot_store, config: Nanoc::Configuration.new({}))
    snapshot_store.set('/stuff.md', :foo, :raw,  item.content.string)
    snapshot_store.set('/stuff.md', :foo, :last, item.content.string)

    # Filter while taking snapshots
    item_rep.snapshot(:foo)
    item_rep.filter(:erb, {}, {})
    item_rep.snapshot(:bar)
    item_rep.filter(:erb, {}, {})
    item_rep.snapshot(:qux)

    # Check snapshots
    assert_equal(%(<%= '<%= "blah" %' + '>' %>), snapshot_store.query(item.identifier, :foo, :foo))
    assert_equal(%(<%= "blah" %>),               snapshot_store.query(item.identifier, :foo, :bar))
    assert_equal(%(blah),                        snapshot_store.query(item.identifier, :foo, :qux))
  end

  def test_filter_text_to_binary
    # Mock item
    item = Nanoc::Item.new(
      'blah blah', {}, '/bwaak.md',
    )

    # Create rep
    rep = Nanoc::ItemRep.new(item, :foo, snapshot_store: new_snapshot_store, config: Nanoc::Configuration.new({}))

    # Create fake filter
    def rep.filter_named(name)
      @filter ||= Class.new(::Nanoc::Filter) do
        type text: :binary
        def run(content, params = {})
          File.write(output_filename, content)
        end
      end
    end

    # Run
    rep.filter(:foo, {}, {})

    # Check
    assert rep.snapshot_binary?(:last)
  end

  def test_filter_with_textual_rep_and_binary_filter
    # Mock item
    item = Nanoc::Item.new(
      'blah blah', {}, '/mockitymock.md',
    )

    # Create rep
    rep = Nanoc::ItemRep.new(item, :foo, snapshot_store: new_snapshot_store, config: Nanoc::Configuration.new({}))
    def rep.assigns
      {}
    end

    # Create fake filter
    def rep.filter_named(name)
      @filter ||= Class.new(::Nanoc::Filter) do
        type :binary
      end
    end

    # Run
    assert_raises ::Nanoc::Errors::CannotUseBinaryFilter do
      rep.filter(:foo, {}, {})
    end
  end

  def test_using_textual_filters_on_binary_reps_raises
    item = create_binary_item
    site = mock_and_stub({
      items: [item],
      layouts: [],
      config: [],
    })
    item.stubs(:site).returns(site)
    rep = create_rep_for(item, :foo)

    assert rep.snapshot_binary?(:last)
    assert_raises(Nanoc::Errors::CannotUseTextualFilter) do
      rep.filter(:text_filter, {}, {})
    end
  end

  def test_converted_binary_rep_can_be_layed_out
    # Mock layout
    layout = Nanoc::Layout.new(%(<%= "blah" %> <%= yield %>), {}, '/somelayout.erb')

    # Create item and item rep
    item = create_binary_item
    snapshot_store = new_snapshot_store
    rep = Nanoc::ItemRep.new(item, :foo, snapshot_store: snapshot_store, config: Nanoc::Configuration.new({}))

    # Create filter
    Class.new(::Nanoc::Filter) do
      type       binary: :text
      identifier :binary_to_text
      def run(content, params = {})
        content + ' textified'
      end
    end

    # Run and check
    rep.filter(:binary_to_text, {}, {})
    rep.layout(layout, :erb, {}, { content: 'meh' })
    assert_equal('blah meh', snapshot_store.query(item.identifier, :foo, :last))
  end

  def test_converted_binary_rep_can_be_filtered_with_textual_filters
    item = create_binary_item
    site = mock_and_stub({
      items: [item],
      layouts: [],
      config: [],
    })
    item.stubs(:site).returns(site)
    rep = create_rep_for(item, :foo)

    assert rep.snapshot_binary?(:last)

    def rep.filter_named(name)
      Class.new(::Nanoc::Filter) do
        type binary: :text
        def run(content, params = {})
          'Some textual content'
        end
      end
    end
    rep.filter(:binary_to_text, {}, {})
    assert !rep.snapshot_binary?(:last)

    def rep.filter_named(name)
      Class.new(::Nanoc::Filter) do
        type :text
        def run(content, params = {})
          'Some textual content'
        end
      end
    end
    rep.filter(:text_filter, {}, {})
    assert !rep.snapshot_binary?(:last)
  end

  def test_converted_binary_rep_cannot_be_filtered_with_binary_filters
    item = create_binary_item
    site = mock_and_stub(
      items: [item],
      layouts: [],
      config: []
    )
    item.stubs(:site).returns(site)
    rep = create_rep_for(item, :foo)

    assert rep.snapshot_binary?(:last)
    def rep.filter_named(name)
      @filter ||= Class.new(::Nanoc::Filter) do
        type binary: :text
        def run(content, params = {})
          'Some textual content'
        end
      end
    end
    rep.filter(:binary_to_text, {}, {})
    refute rep.snapshot_binary?(:last)
    assert_raises(Nanoc::Errors::CannotUseBinaryFilter) do
      rep.filter(:binary_filter, {}, {})
    end
  end

  def test_new_content_should_be_frozen
    filter_class = Class.new(::Nanoc::Filter) do
      def run(content, params = {})
        content.gsub!('foo', 'moo')
        content
      end
    end

    item = Nanoc::Item.new('foo bar', {}, '/foo.md')
    rep = Nanoc::ItemRep.new(item, :default, snapshot_store: new_snapshot_store, config: Nanoc::Configuration.new({}))
    rep.instance_eval { @filter_class = filter_class }
    def rep.filter_named(name)
      @filter_class
    end

    assert_raises_frozen_error do
      rep.filter(:whatever, {}, {})
    end
  end

  def test_filter_should_freeze_content
    filter_class = Class.new(::Nanoc::Filter) do
      def run(content, params = {})
        content.gsub!('foo', 'moo')
      end
    end

    item = Nanoc::Item.new('foo bar', {}, '/foo.md')
    rep = Nanoc::ItemRep.new(item, :default, snapshot_store: new_snapshot_store, config: Nanoc::Configuration.new({}))
    rep.instance_eval { @filter_class = filter_class }
    def rep.filter_named(name)
      @filter_class
    end

    assert_raises_frozen_error do
      rep.filter(:erb, {}, {})
    end
  end

  def test_path_should_generate_dependency
    items = [
      Nanoc::Item.new('foo', {}, '/foo.md'),
      Nanoc::Item.new('bar', {}, '/bar.md')
    ]
    item_reps = [
      Nanoc::ItemRep.new(items[0], :default, snapshot_store: new_snapshot_store, config: Nanoc::Configuration.new({})),
      Nanoc::ItemRep.new(items[1], :default, snapshot_store: new_snapshot_store, config: Nanoc::Configuration.new({}))
    ]

    dt = Nanoc::DependencyTracker.new(items)
    dt.start
    Nanoc::NotificationCenter.post(:visit_started, items[0])
    item_reps[1].path
    Nanoc::NotificationCenter.post(:visit_ended,   items[0])
    dt.stop

    assert_equal [ items[1] ], dt.objects_causing_outdatedness_of(items[0])
  end

  def test_access_compiled_content_of_binary_item
    item = Nanoc::Item.new(Nanoc::BinaryContent.new(File.absolute_path('content/somefile.dat')), {}, '/somefile.dat')
    item_rep = Nanoc::ItemRep.new(item, :foo, snapshot_store: new_snapshot_store, config: Nanoc::Configuration.new({}))
    assert_raises(Nanoc::Errors::CannotGetCompiledContentOfBinaryItem) do
      item_rep.compiled_content
    end
  end

  def test_path_should_strip_index_filenames
    config = Nanoc::Configuration.new({ index_filenames: ['default.html'] })
    item = Nanoc::Item.new('foo', {}, '/foo.md')
    item_rep = Nanoc::ItemRep.new(item, :default, snapshot_store: new_snapshot_store, config: config)
    item_rep.snapshot_paths = {
      raw:          '/foo/donkey.txt',
      after_layout: '/foo/donkey/default.html',
    }

    assert_equal '/foo/donkey.txt',          item_rep.path(snapshot: :raw)
    assert_equal '/foo/donkey/',             item_rep.path(snapshot: :after_layout, strip_index: true)
    assert_equal '/foo/donkey/default.html', item_rep.path(snapshot: :after_layout, strip_index: false)
  end

private

  def create_binary_item
    Nanoc::Item.new(Nanoc::BinaryContent.new('/a/file/name.dat'), {}, '/data.bin')
  end

  def mock_and_stub(params)
    m = mock
    params.each do |method, return_value|
      m.stubs(method.to_sym).returns(return_value)
    end
    m
  end

  def create_rep_for(item, name)
    Nanoc::ItemRep.new(item, name, snapshot_store: new_snapshot_store, config: Nanoc::Configuration.new({}))
  end

end
