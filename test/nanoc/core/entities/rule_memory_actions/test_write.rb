# encoding: utf-8

class Nanoc::RuleMemoryActions::WriteTest < Nanoc::TestCase

  def action
    Nanoc::RuleMemoryActions::Write.new('/raw.txt', :before_layout)
  end

  def test_serialize
    expected = [ :write, '/raw.txt', { snapshot: :before_layout } ]
    assert_equal action.serialize, expected
  end

  def test_to_s
    expected = "write \"/raw.txt\", snapshot: :before_layout"
    assert_equal action.to_s, expected
  end

  def test_inspect
    expected = "<Nanoc::RuleMemoryActions::Write \"/raw.txt\", {:snapshot=>:before_layout}>"
    assert_equal action.inspect, expected
  end

end
