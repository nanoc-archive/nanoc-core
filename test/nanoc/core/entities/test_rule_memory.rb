# encoding: utf-8

class Nanoc::RuleMemoryTest < Nanoc::TestCase

  def new_memory
    item = Nanoc::Item.new(
      Nanoc::TextualContent.new('blah blah blah', File.absolute_path('content/somefile.md')),
      {},
      '/stuff.md')
    snapshot_store = Nanoc::SnapshotStore::InMemory.new
    config = Nanoc::Configuration.new({})
    rep = Nanoc::ItemRep.new(item, :foo, :snapshot_store => snapshot_store, config: config)
    Nanoc::RuleMemory.new(rep)
  end

  def test_serialize_simple
    mem = new_memory

    mem.add_filter(:erb, {})
    mem.add_snapshot(:bar, {})
    mem.add_layout('/default.erb', {})
    mem.add_write('/foo.html', {})

    actual = mem.serialize

    expected = [
      [ :filter, :erb, {} ],
      [ :snapshot, :bar, { path: nil, final: true } ],
      [ :layout, "/default.erb", {} ],
      [ :write, "/foo.html", { snapshot: nil } ],
    ]

    assert_equal expected, actual
  end

  def test_serialize_with_params
    mem = new_memory

    mem.add_filter(:erb, { awesomeness: 123 })
    mem.add_snapshot(:bar, { path: '/asdf.txt' })
    mem.add_layout('/default.erb', { somelayoutparam: 444 })
    mem.add_write('/foo.html', { snapshot: :donkey })

    actual = mem.serialize

    expected = [
      [ :filter, :erb, { awesomeness: 123 } ],
      [ :snapshot, :bar, { path: '/asdf.txt', final: true } ],
      [ :layout, "/default.erb", { somelayoutparam: 444 } ],
      [ :write, "/foo.html", { snapshot: :donkey } ],
    ]

    assert_equal expected, actual
  end

  def test_no_multiple_snapshots
    mem = new_memory

    mem.add_snapshot(:bar, { path: '/asdf.txt' })
    assert_raises(CannotCreateMultipleSnapshotsWithSameName) do
      mem.add_write('/fdsa.txt', { snapshot: :bar })
    end
  end

end
