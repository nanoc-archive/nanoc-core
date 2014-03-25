# encoding: utf-8

class Nanoc::ItemRepViewForRuleProcessingTest < Nanoc::TestCase

  def setup
    super

    @snapshot_store = Nanoc::SnapshotStore::InMemory.new
    @content = Nanoc::TextualContent.new('blah blah blah', File.absolute_path('content/somefile.md'))
    @item = Nanoc::Item.new(@content, {}, '/index.md')
    @item_rep = Nanoc::ItemRep.new(@item, :foo, snapshot_store: @snapshot_store, config: Nanoc::Configuration.new({}))
    def @item_rep.compiled_content(params = {})
      "default content at #{params[:snapshot].inspect}"
    end
    def @item_rep.path(params = {})
      "default path at #{params[:snapshot].inspect}"
    end
    compiler = nil

    @subject = Nanoc::ItemRepViewForRuleProcessing.new(@item_rep, compiler)
  end

  def test_resolve
    assert_equal @item_rep, @subject.resolve
  end

  def test_name
    assert_equal :foo, @subject.name
  end

  def test_inspect
    assert_match(/Nanoc::ItemRep*/, @subject.inspect)
  end

  def test_layout_with_identifier
    def @subject.layouts
      [
        Nanoc::Layout.new('blah', {}, '/foo.erb'),
        Nanoc::Layout.new('blah', {}, '/bar.erb'),
      ]
    end

    refute_nil @subject.send(:layout_with_identifier, '/foo.erb')
    refute_nil @subject.send(:layout_with_identifier, '/foo.*')
    refute_nil @subject.send(:layout_with_identifier, '/bar.erb')
    refute_nil @subject.send(:layout_with_identifier, '/bar.*')

    assert_raises(Nanoc::Errors::UnknownLayout) do
      @subject.send(:layout_with_identifier, '/qux.erb')
    end

    assert_raises(Nanoc::Errors::UnknownLayout) do
      @subject.send(:layout_with_identifier, '/qux.*')
    end

    assert_raises(Nanoc::Errors::NoSingleValueForPattern) do
      @subject.send(:layout_with_identifier, '/*.erb')
    end
  end

end
