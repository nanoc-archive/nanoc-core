# encoding: utf-8

class Nanoc::DependencyTrackerTest < Nanoc::TestCase

  class MockDataSource < ::Nanoc::DataSource

    attr_reader :items
    attr_reader :layouts

    def initialize(items, layouts, *rest)
      @items = items
      @layouts = layouts
      super(*rest)
    end

  end

  def new_item_collection(items=nil)
    data_source = MockDataSource.new(
      items || [
        Nanoc::Item.new("Foo!", {}, "/foo.md"),
        Nanoc::Item.new("Bar!", {}, "/bar.md"),
        Nanoc::Item.new("Qux!", {}, "/qux.md"),
        Nanoc::Item.new("Pop!", {}, "/pop.md"),
      ],
      [],
      '/',
      '/',
      {}
    )

    Nanoc::ItemCollection.new([ data_source ])
  end

  def test_initialize
    # Mock objects
    items = new_item_collection
    layouts = []

    # Create
    tracker = Nanoc::DependencyTracker.new(items, layouts)

    # Verify no dependencies yet
    assert_empty tracker.objects_causing_outdatedness_of(items['/foo.md'])
    assert_empty tracker.objects_causing_outdatedness_of(items['/bar.md'])
  end

  def test_record_dependency
    # Mock objects
    items = new_item_collection
    layouts = []

    # Create
    tracker = Nanoc::DependencyTracker.new(items, layouts)

    # Record some dependencies
    tracker.record_dependency(items['/foo.md'], items['/bar.md'])

    # Verify dependencies
    assert_contains_exactly [ items['/bar.md'] ],
      tracker.objects_causing_outdatedness_of(items['/foo.md'])
    assert_contains_exactly [],
      tracker.objects_causing_outdatedness_of(items['/bar.md'])
  end

  def test_record_dependency_no_self
    # Mock objects
    items = new_item_collection
    layouts = []

    # Create
    tracker = Nanoc::DependencyTracker.new(items, layouts)

    # Record some dependencies
    tracker.record_dependency(items['/foo.md'], items['/foo.md'])
    tracker.record_dependency(items['/foo.md'], items['/bar.md'])

    # Verify dependencies
    assert_contains_exactly [ items['/bar.md'] ],
      tracker.objects_causing_outdatedness_of(items['/foo.md'])
  end

  def test_record_dependency_no_doubles
    # Mock objects
    items = new_item_collection
    layouts = []

    # Create
    tracker = Nanoc::DependencyTracker.new(items, layouts)

    # Record some dependencies
    tracker.record_dependency(items['/foo.md'], items['/bar.md'])
    tracker.record_dependency(items['/foo.md'], items['/bar.md'])
    tracker.record_dependency(items['/foo.md'], items['/bar.md'])

    # Verify dependencies
    assert_contains_exactly [ items['/bar.md'] ],
      tracker.objects_causing_outdatedness_of(items['/foo.md'])
  end

  def test_objects_causing_outdatedness_of
    # Mock objects
    items = new_item_collection
    layouts = []

    # Create
    tracker = Nanoc::DependencyTracker.new(items, layouts)

    # Record some dependencies
    tracker.record_dependency(items['/foo.md'], items['/bar.md'])
    tracker.record_dependency(items['/bar.md'], items['/qux.md'])

    # Verify dependencies
    assert_contains_exactly [ items['/bar.md'] ], tracker.objects_causing_outdatedness_of(items['/foo.md'])
  end

  def test_objects_outdated_due_to
    # Mock objects
    items = new_item_collection
    layouts = []

    # Create
    tracker = Nanoc::DependencyTracker.new(items, layouts)

    # Record some dependencies
    tracker.record_dependency(items['/foo.md'], items['/bar.md'])
    tracker.record_dependency(items['/bar.md'], items['/qux.md'])

    # Verify dependencies
    assert_contains_exactly [ items['/foo.md'] ], tracker.objects_outdated_due_to(items['/bar.md'])
  end

  def test_start_and_stop
    # Mock objects
    items = new_item_collection
    layouts = []

    # Create
    tracker = Nanoc::DependencyTracker.new(items, layouts)

    # Start, do something and stop
    begin
      tracker.start
      Nanoc::NotificationCenter.post(:visit_started, items['/foo.md'])
      Nanoc::NotificationCenter.post(:visit_started, items['/bar.md'])
      Nanoc::NotificationCenter.post(:visit_ended,   items['/bar.md'])
      Nanoc::NotificationCenter.post(:visit_ended,   items['/foo.md'])
    ensure
      tracker.stop
    end

    # Verify dependencies
    assert_contains_exactly [ items['/bar.md'] ], tracker.objects_causing_outdatedness_of(items['/foo.md'])
    assert_empty tracker.objects_causing_outdatedness_of(items['/bar.md'])
  end

  def test_store_and_load_simple
    # Mock objects
    items = new_item_collection
    layouts = []

    # Create
    tracker = Nanoc::DependencyTracker.new(items, layouts)

    # Record some dependencies
    tracker.record_dependency(items['/foo.md'], items['/bar.md'])
    tracker.record_dependency(items['/bar.md'], items['/qux.md'])
    tracker.record_dependency(items['/bar.md'], items['/pop.md'])

    # Store
    tracker.store
    assert File.file?(tracker.filename)

    # Re-create
    tracker = Nanoc::DependencyTracker.new(items, layouts)

    # Load
    tracker.load

    # Check loaded graph
    assert_contains_exactly [ items['/bar.md'] ],           tracker.objects_causing_outdatedness_of(items['/foo.md'])
    assert_contains_exactly [ items['/qux.md'], items['/pop.md'] ], tracker.objects_causing_outdatedness_of(items['/bar.md'])
    assert_empty tracker.objects_causing_outdatedness_of(items['/qux.md'])
    assert_empty tracker.objects_causing_outdatedness_of(items['/pop.md'])
  end

  def test_store_and_load_with_removed_items
    # Mock objects
    items = new_item_collection
    layouts = []

    # Create new and old lists
    old_items = new_item_collection([
      items['/foo.md'],
      items['/bar.md'],
      items['/qux.md'],
      items['/pop.md'],
    ])
    new_items = new_item_collection([
      items['/foo.md'],
      items['/bar.md'],
      items['/qux.md'],
    ])

    # Create
    tracker = Nanoc::DependencyTracker.new(items, layouts)

    # Record some dependencies
    tracker.record_dependency(items['/foo.md'], items['/bar.md'])
    tracker.record_dependency(items['/bar.md'], items['/qux.md'])
    tracker.record_dependency(items['/bar.md'], items['/pop.md'])

    # Store
    tracker.store
    assert File.file?(tracker.filename)

    # Re-create
    tracker = Nanoc::DependencyTracker.new(new_items, layouts)

    # Load
    tracker.load

    # Check loaded graph
    assert_contains_exactly [ items['/bar.md'] ],
      tracker.objects_causing_outdatedness_of(items['/foo.md'])
    assert_contains_exactly [ items['/qux.md'], nil ],
      tracker.objects_causing_outdatedness_of(items['/bar.md'])
    assert_empty tracker.objects_causing_outdatedness_of(items['/qux.md'])
  end

  def test_forget_dependencies_for
    # Mock objects
    items = new_item_collection
    layouts = []

    # Create
    tracker = Nanoc::DependencyTracker.new(items, layouts)

    # Record some dependencies
    tracker.record_dependency(items['/foo.md'], items['/bar.md'])
    tracker.record_dependency(items['/bar.md'], items['/qux.md'])
    assert_contains_exactly [ items['/bar.md'] ], tracker.objects_causing_outdatedness_of(items['/foo.md'])

    # Forget dependencies
    tracker.forget_dependencies_for(items['/foo.md'])
    assert_empty tracker.objects_causing_outdatedness_of(items['/foo.md'])
  end

end
