# encoding: utf-8

class Nanoc::FilterTest < Nanoc::TestCase

  def test_initialize
    # Create filter
    filter = Nanoc::Filter.new

    # Test assigns
    assert_equal({}, filter.instance_eval { @assigns })
  end

  def test_assigns
    # Create filter
    filter = Nanoc::Filter.new({ foo: 'bar' })

    # Check assigns
    assert_equal('bar', filter.assigns[:foo])
  end

  def test_assigns_with_instance_variables
    # Create filter
    filter = Nanoc::Filter.new({ foo: 'bar' })

    # Check assigns
    assert_equal('bar', filter.instance_eval { @foo })
  end

  def test_assigns_with_instance_methods
    # Create filter
    filter = Nanoc::Filter.new({ foo: 'bar' })

    # Check assigns
    assert_equal('bar', filter.instance_eval { foo })
  end

  def test_run
    # Create filter
    filter = Nanoc::Filter.new

    # Make sure an error is raised
    assert_raises(NotImplementedError) do
      filter.run(nil)
    end
  end

  def test_filename_item
    # Mock items
    item = mock
    item.expects(:identifier).returns('/foo/bar/baz/')
    item_rep = mock
    item_rep.expects(:name).returns(:quux)

    # Create filter
    filter = Nanoc::Filter.new({ item: item, item_rep: item_rep })

    # Check filename
    assert_equal('item /foo/bar/baz/ (rep quux)', filter.filename)
  end

  def test_filename_layout
    # Mock items
    layout = mock
    layout.expects(:identifier).returns('/wohba/')

    # Create filter
    filter = Nanoc::Filter.new({ item: mock, item_rep: mock, layout: layout })

    # Check filename
    assert_equal('layout /wohba/', filter.filename)
  end

  def test_filename_unknown
    # Create filter
    filter = Nanoc::Filter.new({})

    # Check filename
    assert_equal('?', filter.filename)
  end

  class ItemWrapper

    def initialize(item, rep)
      @item = item
      @rep  = rep
    end

    def resolve
      @item
    end

    def reps
      [ @rep ]
    end

  end

  def test_depend_on_compiled
    snapshot_store = Nanoc::SnapshotStore::InMemory.new
    config = Nanoc::Configuration.new({})

    item = Nanoc::Item.new('stuff', { count: 0 }, '/stuff.md')
    rep = Nanoc::ItemRep.new(item, :foo, snapshot_store: snapshot_store, config: config)
    rep.compiled = true

    wrapped_item = ItemWrapper.new(item, rep)

    Nanoc::NotificationCenter.on(:visit_started, self) do |item|
      item.attributes[:count] = item.attributes[:count] + 1
    end
    Nanoc::NotificationCenter.on(:visit_ended, self) do |item|
      item.attributes[:count] = item.attributes[:count] + 10
    end

    filter = Nanoc::Filter.new({})
    filter.depend_on([ wrapped_item ])

    assert_equal 1 + 10, item.attributes[:count]
  ensure
    Nanoc::NotificationCenter.remove(:visit_started, self)
    Nanoc::NotificationCenter.remove(:visit_ended, self)
  end

  def test_depend_on_not_compiled
    snapshot_store = Nanoc::SnapshotStore::InMemory.new
    config = Nanoc::Configuration.new({})

    item = Nanoc::Item.new('stuff', { count: 0 }, '/stuff.md')
    rep = Nanoc::ItemRep.new(item, :foo, snapshot_store: snapshot_store, config: config)
    rep.compiled = false

    wrapped_item = ItemWrapper.new(item, rep)

    filter = Nanoc::Filter.new({})
    assert_raises(Nanoc::Errors::UnmetDependency) do
      filter.depend_on([ wrapped_item ])
    end
  end

end
