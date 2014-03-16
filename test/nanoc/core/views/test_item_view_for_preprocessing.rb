# encoding: utf-8

class Nanoc::ItemViewForPreprocessingTest < Nanoc::TestCase

  def setup
    super

    @content = Nanoc::TextualContent.new('blah blah blah', File.absolute_path('content/somefile.md'))
    @item = Nanoc::Item.new(@content, {foo: 123}, '/index.md')
    @item_view = Nanoc::ItemViewForPreprocessing.new(@item)
  end

  def test_resolve
    assert_equal @item, @item_view.resolve
  end

  def test_identifier
    assert_equal @item_view.identifier, @item.identifier
  end

  def test_get
    assert_equal @item_view[:foo], 123
  end

  def test_set
    @item_view[:foo] = 456
    assert_equal @item_view[:foo], 456
    assert_equal @item.attributes[:foo], 456
  end

end
