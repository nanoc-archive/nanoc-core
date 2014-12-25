# encoding: utf-8

class Nanoc::RuleMemoryActions::SnapshotTest < Nanoc::TestCase
  def action
    Nanoc::RuleMemoryActions::Snapshot.new(:before_layout, '/raw.txt', true)
  end

  def test_serialize
    expected = [:snapshot, :before_layout, { path: '/raw.txt', final: true }]
    assert_equal action.serialize, expected
  end

  def test_to_s
    expected = "snapshot :before_layout, path: \"/raw.txt\", final: true"
    assert_equal action.to_s, expected
  end

  def test_inspect
    expected = "<Nanoc::RuleMemoryActions::Snapshot :before_layout, {:path=>\"/raw.txt\", :final=>true}>"
    assert_equal action.inspect, expected
  end
end
