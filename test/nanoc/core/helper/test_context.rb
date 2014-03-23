# encoding: utf-8

class Nanoc::ContextTest < Nanoc::TestCase

  def test_context_with_instance_variable
    # Create context
    context = Nanoc::Context.new({ foo: 'bar', baz: 'quux' })

    # Ensure correct evaluation
    assert_equal('bar', eval('@foo', context._binding))
  end

  def test_context_with_instance_method
    # Create context
    context = Nanoc::Context.new({ foo: 'bar', baz: 'quux' })

    # Ensure correct evaluation
    assert_equal('bar', eval('foo', context._binding))
  end

  def test_example
    YARD.parse(LIB_DIR + '/nanoc/core/helper/context.rb')
    assert_examples_correct 'Nanoc::Context#initialize'
  end

end
