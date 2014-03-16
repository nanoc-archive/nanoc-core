# encoding: utf-8

class Nanoc::RuleMemoryActions::LayoutTest < Nanoc::TestCase

  def action
    Nanoc::RuleMemoryActions::Layout.new('/default.erb', { awesome: true })
  end

  def test_serialize
    expected = [ :layout, '/default.erb', { awesome: true } ]
    assert_equal action.serialize, expected
  end

  def test_to_s
    expected = "layout \"/default.erb\", {:awesome=>true}"
    assert_equal action.to_s, expected
  end

  def test_inspect
    expected = "<Nanoc::RuleMemoryActions::Layout \"/default.erb\", {:awesome=>true}>"
    assert_equal action.inspect, expected
  end

end
