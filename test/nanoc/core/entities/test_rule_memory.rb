# encoding: utf-8

class Nanoc::RuleMemoryTest < Nanoc::TestCase
  def new_memory
    item = Nanoc::Item.new(
      Nanoc::TextualContent.new('blah blah blah', File.absolute_path('content/somefile.md')),
      {},
      '/stuff.md')
    snapshot_store = Nanoc::SnapshotStore::InMemory.new
    config = Nanoc::Configuration.new({})
    rep = Nanoc::ItemRep.new(item, :foo, snapshot_store: snapshot_store, config: config)
    Nanoc::RuleMemory.new(rep)
  end

  def test_serialize
    mem = new_memory

    mem.add_filter(:erb, { awesomeness: 123 })
    mem.add_snapshot(:bar, nil, true)
    mem.add_layout('/default.erb', { somelayoutparam: 444 })
    mem.add_write('/foo.html', nil)

    actual = mem.serialize

    expected = [
      [:filter, :erb, { awesomeness: 123 }],
      [:snapshot, :bar, { path: nil, final: true }],
      [:layout, '/default.erb', { somelayoutparam: 444 }],
      [:write, '/foo.html', { snapshot: :last }], # last snapshotless write
    ]

    assert_equal expected, actual
  end

  def test_serialize_with_params
    mem = new_memory

    mem.add_filter(:erb, { awesomeness: 123 })
    mem.add_snapshot(:bar, '/stuff.txt', false)
    mem.add_layout('/default.erb', { somelayoutparam: 444 })
    mem.add_write('/foo.html', :donkey)

    actual = mem.serialize

    expected = [
      [:filter, :erb, { awesomeness: 123 }],
      [:snapshot, :bar, { path: '/stuff.txt', final: false }],
      [:layout, '/default.erb', { somelayoutparam: 444 }],
      [:write, '/foo.html', { snapshot: :donkey }],
    ]

    assert_equal expected, actual
  end

  def test_no_multiple_snapshots
    mem = new_memory

    mem.add_snapshot(:bar, '/asdf.txt', true)
    assert_raises(Nanoc::Errors::CannotCreateMultipleSnapshotsWithSameName) do
      mem.add_write('/fdsa.txt', :bar)
    end
  end

  def test_last_snapshotless_write
    mem = new_memory

    mem.add_write('/aaa.txt', nil)
    mem.add_write('/bbb.txt', :foo)
    mem.add_write('/ccc.txt', nil)

    expected = [
      [:write, '/aaa.txt', { snapshot: nil }],
      [:write, '/bbb.txt', { snapshot: :foo }],
      [:write, '/ccc.txt', { snapshot: :last }],
    ]

    assert_equal expected, mem.serialize
  end

  def test_not_last_snapshotless_write
    mem = new_memory

    mem.add_write('/aaa.txt', nil)
    mem.add_write('/bbb.txt', :foo)
    mem.add_write('/ccc.txt', :bar)

    expected = [
      [:write, '/aaa.txt', { snapshot: nil }],
      [:write, '/bbb.txt', { snapshot: :foo }],
      [:write, '/ccc.txt', { snapshot: :bar }],
    ]

    assert_equal expected, mem.serialize
  end
end
