# encoding: utf-8

class Nanoc::ItemViewTest < Nanoc::TestCase

  def setup
    super

    @snapshot_store = Nanoc::SnapshotStore::InMemory.new
    @content = Nanoc::TextualContent.new('blah blah blah', File.absolute_path('content/somefile.md'))
    @item = Nanoc::Item.new(@content, {}, '/index.md')
    @rep_1 = Nanoc::ItemRep.new(@item, :default, :snapshot_store => @snapshot_store)
    @rep_2 = Nanoc::ItemRep.new(@item, :foo,     :snapshot_store => @snapshot_store)
    def @rep_1.compiled_content(params={}) ; "default content at #{params[:snapshot].inspect}" ; end
    def @rep_2.compiled_content(params={}) ; "foo content at #{params[:snapshot].inspect}" ; end
    def @rep_1.path(params={}) ; "default path at #{params[:snapshot].inspect}" ; end
    def @rep_2.path(params={}) ; "foo path at #{params[:snapshot].inspect}" ; end
    @item_rep_store = Nanoc::ItemRepStore.new([ @rep_1, @rep_2 ])
    @subject = Nanoc::ItemView.new(@item, @item_rep_store)
  end

  def test_resolve
    assert_equal @item, @subject.resolve
  end

  def test_reps
    expected = [ @rep_1, @rep_2 ].to_set
    assert_equal expected, @subject.reps.to_set.map { |r| r.resolve }.to_set
  end

  def test_rep_named
    refute_equal @rep_2, @subject.rep_named(:foo)
    assert_equal @rep_2, @subject.rep_named(:foo).resolve
  end

  def test_compiled_content_with_default_rep_and_default_snapshot
    assert_equal 'default content at nil', @subject.compiled_content
  end

  def test_compiled_content_with_custom_rep_and_default_snapshot
    assert_equal 'foo content at nil', @subject.compiled_content(:rep => :foo)
  end

  def test_compiled_content_with_default_rep_and_custom_snapshot
    assert_equal 'default content at :blah', @subject.compiled_content(:snapshot => :blah)
  end

  def test_compiled_content_with_custom_nonexistant_rep
    assert_raises(Nanoc::Errors::Generic) do
      @subject.compiled_content(:rep => :lkasdhflahgwfe)
    end
  end

  def test_path_with_default_rep
    assert_equal 'default path at nil', @subject.path
  end

  def test_path_with_custom_rep
    assert_equal 'foo path at nil', @subject.path(:rep => :foo)
  end

  def test_path_with_custom_nonexistant_rep
    assert_raises(Nanoc::Errors::Generic) do
      assert_equal 'foo path at nil', @subject.path(:rep => :sdfklgh)
    end
  end

  def test_path_with_default_snapshot
    assert_equal 'default path at nil', @subject.path
  end

  def test_path_with_custom_snapshot
    assert_equal 'default path at :blargh', @subject.path(:snapshot => :blargh)
  end

  def test_binary
    refute @subject.binary?
  end

end
