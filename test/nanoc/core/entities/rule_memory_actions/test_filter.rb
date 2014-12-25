# encoding: utf-8

class Nanoc::RuleMemoryActions::FilterTest < Nanoc::TestCase
  def action
    Nanoc::RuleMemoryActions::Filter.new(:foo, { awesome: true })
  end

  def test_serialize
    expected = [:filter, :foo, { awesome: true }]
    assert_equal action.serialize, expected
  end

  def test_to_s
    expected = 'filter :foo, {:awesome=>true}'
    assert_equal action.to_s, expected
  end

  def test_inspect
    expected = '<Nanoc::RuleMemoryActions::Filter :foo, {:awesome=>true}>'
    assert_equal action.inspect, expected
  end
end
