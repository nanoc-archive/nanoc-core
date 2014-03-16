# encoding: utf-8

class Nanoc::LayoutTest < Nanoc::TestCase

  def test_initialize
    layout = Nanoc::Layout.new("content", { 'foo' => 'bar' }, '/foo')
    assert_equal({ :foo => 'bar' }, layout.attributes)
  end

  def test_frozen_identifier
    layout = Nanoc::Layout.new("foo", {}, '/foo')

    assert_raises_frozen_error do
      layout.identifier.components << 'blah'
    end

    assert_raises_frozen_error do
      layout.identifier.components[0] << 'blah'
    end
  end

  def test_lookup_with_known_attribute
    # Create layout
    layout = Nanoc::Layout.new("content", { 'foo' => 'bar' }, '/foo')

    # Check attributes
    assert_equal('bar', layout.attributes[:foo])
  end

  def test_lookup_with_unknown_attribute
    # Create layout
    layout = Nanoc::Layout.new("content", { 'foo' => 'bar' }, '/foo')

    # Check attributes
    assert_equal(nil, layout.attributes[:filter])
  end

end
