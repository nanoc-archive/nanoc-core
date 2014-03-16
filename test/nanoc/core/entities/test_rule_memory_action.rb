# encoding: utf-8

class Nanoc::RuleMemoryActionTest < Nanoc::TestCase

  def test_abstract
    action = Nanoc::RuleMemoryAction.new

    assert_raises(NotImplementedError) { action.serialize }
    assert_raises(NotImplementedError) { action.to_s }
    assert_raises(NotImplementedError) { action.inspect }
  end

end
