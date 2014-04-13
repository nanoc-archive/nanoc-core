# encoding: utf-8

describe Nanoc::DocumentView do

  let(:content) do
    Nanoc::TextualContent.new('blah blah blah', File.absolute_path('content/somefile.md'))
  end

  let(:item) do
    Nanoc::Item.new(content, {}, '/index.md')
  end

  let(:other_item) do
    Nanoc::Item.new(content, {}, '/somethingelse.md')
  end

  let(:layout) do
    Nanoc::Layout.new(content, {}, '/index.md')
  end

  subject do
    Nanoc::DocumentView.new(item)
  end

  describe '#resolve' do

    it 'should work' do
      subject.resolve.must_equal(item)
    end

  end

  describe '#== and #eql?' do

    it 'should work when comparing to objects of the same type' do
      (subject == Nanoc::DocumentView.new(item)).must_equal(true)
    end

    it 'should work when comparing to objects of similar type' do
      (subject == item).must_equal(true)
    end

    it 'should fail when comparing to objects of different type' do
      (subject == layout).must_equal(false)
    end

    it 'should fail when comparing to objects of same type but different identifier' do
      (subject == other_item).must_equal(false)
    end

  end

end
