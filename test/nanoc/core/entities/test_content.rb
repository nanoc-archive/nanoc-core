# encoding: utf-8

class Nanoc::ContentTest < Nanoc::TestCase

  def test_abstract
    content = Nanoc::Content.new('/foo.html')

    assert_raises(NotImplementedError) { content.binary? }
    assert_raises(NotImplementedError) { content.checksum }
  end

  def test_valid_filename
    Nanoc::Content.new('/foo.html')
    Nanoc::Content.new(nil)

    assert_raises(ArgumentError) do
      Nanoc::Content.new('foo.html')
    end
  end

end
