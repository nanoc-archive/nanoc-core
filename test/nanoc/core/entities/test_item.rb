# encoding: utf-8

class Nanoc::ItemTest < Nanoc::TestCase

  def test_initialize_with_attributes_with_string_keys
    item = Nanoc::Item.new("foo", { 'abc' => 'xyz' }, '/foo.md')

    assert_equal nil,   item.attributes['abc']
    assert_equal 'xyz', item.attributes[:abc]
  end

  def test_initialize_without_content
    error = assert_raises ArgumentError do
      Nanoc::Item.new(nil, {}, '/foo.md')
    end

    assert_equal 'Attempted to create a Nanoc::Item without content (identifier /foo.md)', error.message
  end

  def test_frozen_identifier
    item = Nanoc::Item.new("foo", {}, '/foo')

    assert_raises_frozen_error do
      item.identifier.components << 'blah'
    end

    assert_raises_frozen_error do
      item.identifier.components[0] << 'blah'
    end
  end

  def test_lookup
    # Create item
    item = Nanoc::Item.new(
      "content",
      { :one => 'one in item' },
      '/path.md'
    )

    # Test finding one
    assert_equal('one in item', item.attributes[:one])

    # Test finding two
    assert_equal(nil, item.attributes[:two])
  end

  def test_freeze_should_disallow_changes
    item = Nanoc::Item.new("foo", { :a => { :b => 123 }}, '/foo')
    item.freeze

    assert_raises_frozen_error do
      item.attributes[:a][:b] = '456'
    end
  end

end
