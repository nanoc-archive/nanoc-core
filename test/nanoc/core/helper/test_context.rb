# encoding: utf-8

class Nanoc::ContextTest < Nanoc::TestCase

  def test_context_with_instance_variable
    # Create context
    context = Nanoc::Context.new({ :foo => 'bar', :baz => 'quux' })

    # Ensure correct evaluation
    assert_equal('bar', eval("@foo", context.get_binding))
  end

  def test_context_with_instance_method
    # Create context
    context = Nanoc::Context.new({ :foo => 'bar', :baz => 'quux' })

    # Ensure correct evaluation
    assert_equal('bar', eval("foo", context.get_binding))
  end

  def test_example
    YARD.parse(File.dirname(__FILE__) + '/../../../../lib/nanoc/core/helper/context.rb')
    assert_examples_correct 'Nanoc::Context#initialize'
  end

end
