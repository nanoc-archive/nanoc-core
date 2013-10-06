# encoding: utf-8

class Nanoc::ItemCollectionTest < Nanoc::TestCase

  def setup
    super

    @one = Nanoc::Item.new(
      Nanoc::TextualContent.new('Item One', File.join(Dir.getwd, 'content/one.md')),
      {},
      '/one.md')
    @two = Nanoc::Item.new(
      Nanoc::TextualContent.new('Item Two', File.join(Dir.getwd, 'content/two.css')),
      {},
      '/two.css')

    @items = Nanoc::ItemCollection.new
    @items << @one
    @items << @two
  end

  def test_change_item_identifier
    assert_equal @one, @items['/one.md']
    assert_nil @items['/foo.txt']

    @one.identifier = '/foo.txt'

    assert_nil @items['/one.md']
    assert_equal @one, @items['/foo.txt']
  end

  def test_enumerable
    assert_equal @one, @items.find { |i| i.identifier == '/one.md' }
  end

  def test_glob
    assert_equal [],                         @items.glob('/three.*').map { |i| i.content.string }
    assert_equal [ 'Item One' ],             @items.glob('/one.*').map   { |i| i.content.string }
    assert_equal [ 'Item Two' ],             @items.glob('/two.*').map   { |i| i.content.string }
    assert_equal [ 'Item One', 'Item Two' ], @items.glob('/*o*.*').map   { |i| i.content.string }
  end

  def test_brackets_and_slice_and_at_with_string_identifier
    assert_equal @one, @items['/one.md']
    assert_equal @one, @items.slice('/one.md')
    assert_equal @one, @items.at('/one.md')

    assert_equal @two, @items['/two.css']
    assert_equal @two, @items.slice('/two.css')
    assert_equal @two, @items.at('/two.css')

    assert_nil @items['/max-payne/']
    assert_nil @items.slice('/max-payne/')
    assert_nil @items.at('/max-payne/')
  end

  def test_brackets_and_slice_and_at_with_object_identifier
    identifier_one = Nanoc::Identifier.from_string('/one.md')
    assert_equal @one, @items[identifier_one]
    assert_equal @one, @items.slice(identifier_one)
    assert_equal @one, @items.at(identifier_one)

    identifier_two = Nanoc::Identifier.from_string('/two.css')
    assert_equal @two, @items[identifier_two]
    assert_equal @two, @items.slice(identifier_two)
    assert_equal @two, @items.at(identifier_two)

    identifier_max_payne = Nanoc::Identifier.from_string('/max-payne/')
    assert_nil @items[identifier_max_payne]
    assert_nil @items.slice(identifier_max_payne)
    assert_nil @items.at(identifier_max_payne)
  end

  def test_brackets_and_slice_and_at_with_malformed_identifier
    assert_nil @items['one/']
    assert_nil @items.slice('one/')
    assert_nil @items.at('one/')

    assert_nil @items['/one']
    assert_nil @items.slice('/one')
    assert_nil @items.at('/one')

    assert_nil @items['one']
    assert_nil @items.slice('one')
    assert_nil @items.at('one')

    assert_nil @items['//one.md']
    assert_nil @items.slice('//one.md')
    assert_nil @items.at('//one.md')
  end

  def test_brackets_and_slice_and_at_frozen
    @items.freeze

    assert_equal @one, @items['/one.md']
    assert_equal @one, @items.slice('/one.md')
    assert_equal @one, @items.at('/one.md')

    assert_nil @items['/tenthousand/']
    assert_nil @items.slice('/tenthousand/')
    assert_nil @items.at('/tenthousand/')
  end

  def test_less_than_less_than
    assert_nil @items['/foo.txt']

    foo = Nanoc::Item.new('Item Foo', {}, '/foo.txt')
    @items << foo

    assert_equal foo, @items['/foo.txt']
  end

  def test_clear
    @items.clear

    assert_nil @items['/one.md']
    assert_nil @items['/two.css']
  end

  def test_collect_bang
    @items.collect! do |i|
      Nanoc::Item.new("New #{i.content.string}", {}, "/new#{i.identifier}")
    end

    assert_nil @items['/one.md']
    assert_nil @items['/two.css']

    assert_equal "New Item One", @items['/new/one.md'].content.string
    assert_equal "New Item Two", @items['/new/two.css'].content.string
  end

  def test_collect_bang_frozen
    @items.freeze

    assert_raises_frozen_error do
      @items.collect! do |i|
        Nanoc::Item.new("New #{i.content.string}", {}, "/new#{i.identifier}")
      end
    end
  end

  def test_concat
    new_item = Nanoc::Item.new('New item', {}, '/new.md')
    @items.concat([ new_item ])
    assert_equal new_item, @items['/new.md']
  end

  def test_delete
    assert_equal @two, @items['/two.css']
    @items.delete(@two)
    assert_nil @items['/two.css']
  end

  def test_delete_if
    assert_equal @two, @items['/two.css']
    @items.delete_if { |i| i.identifier == '/two.css' }
    assert_nil @items['/two.css']
  end

  def test_reject_bang
    assert_equal @two, @items['/two.css']
    @items.reject! { |i| i.identifier == '/two.css' }
    assert_nil @items['/two.css']
  end

  def test_select_bang
    assert_equal @two, @items['/two.css']
    @items.select! { |i| i.identifier == '/two.css' }
    assert_nil @items['/one.md']
  end

end
