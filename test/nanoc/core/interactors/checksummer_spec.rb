# encoding: utf-8

require 'tempfile'

describe Nanoc::Checksummer do

  subject { Nanoc::Checksummer.new }

  CHECKSUM_REGEX = /\A[0-9a-f]{40}\Z/

  describe 'for String' do

    it 'should checksum strings' do
      subject.calc('foo').must_equal('0beec7b5ea3f0fdbc95d0dd47f3c5bc275da8a33')
    end

  end

  describe 'for Array' do

    it 'should checksum arrays' do
      subject.calc([1, 'a', :a]).must_equal 'f66788fdbaf5dba7f047fc76e4312e0e4eefc147'
    end

    it 'should take order into account when checksumming arrays' do
      subject.calc([:a, 'a', 1]).wont_equal(subject.calc([1, 'a', :a]))
    end

    it 'should checksum non-serializable arrays' do
      subject.calc([-> {}]).must_match(CHECKSUM_REGEX)
    end

  end

  describe 'for Hash' do

    it 'should checksum hashes' do
      subject.calc({ a: 1, b: 2 }).must_equal '58df4c0192c6a26f9921bba82704457b9e40e755'
    end

    it 'should take order into account when checksumming hashes' do
      subject.calc({ a: 1, b: 2 }).wont_equal(subject.calc({ b: 2, a: 1 }))
    end

    it 'should checksum non-serializable hashes' do
      subject.calc({ a: ->{} }).must_match(CHECKSUM_REGEX)
    end

  end

  describe 'for Nanoc::BinaryContent' do

    let(:file)            { Tempfile.new('foo') }
    let(:filename)        { file.path }
    let(:binary_content)  { Nanoc::BinaryContent.new(filename) }
    let(:atime)           { 1234567890 }
    let(:mtime)           { 1234567890 }
    let(:data)            { 'stuffs' }
    let(:normal_checksum) { '36c457097e4d9d16cd1fb469c29d4f970c44568c' }

    before do
      file.write(data)
      file.close
      File.utime(atime, mtime, filename)
    end

    after do
      file.unlink
    end

    it 'should get the mtime right' do
      stat = File.stat(filename)
      stat.mtime.to_i.must_equal(mtime)
    end

    it 'should get the file size right' do
      stat = File.stat(filename)
      stat.size.must_equal(6)
    end

    it 'should checksum binary content' do
      subject.calc(binary_content).must_equal(normal_checksum)
    end

    describe 'if the mtime changes' do

      let(:mtime) { 1333333333 }

      it 'should have a different checksum' do
        subject.calc(binary_content).must_match(CHECKSUM_REGEX)
        subject.calc(binary_content).wont_equal(normal_checksum)
      end

    end

    describe 'if the content changes, but not the file size' do

      let(:data) { 'STUFF!' }

      it 'should have the same checksum' do
        subject.calc(binary_content).must_match(CHECKSUM_REGEX)
        subject.calc(binary_content).must_equal(normal_checksum)
      end

    end

    describe 'if the file size changes' do

      let(:data) { 'stuff and stuff and stuff!!!' }

      it 'should have a different checksum' do
        subject.calc(binary_content).must_match(CHECKSUM_REGEX)
        subject.calc(binary_content).wont_equal(normal_checksum)
      end

    end

  end

  describe 'for Nanoc::TextualContent' do

    let(:string)          { 'asdf' }
    let(:filename)        { File.expand_path('bob.txt') }
    let(:textual_content) { Nanoc::TextualContent.new(string, filename) }

    it 'should checksum the string' do
      subject.calc(textual_content).must_equal(subject.calc(string))
    end

  end

  describe 'for Nanoc::CodeSnippet' do

    let(:data)         { 'asdf' }
    let(:filename)     { File.expand_path('bob.txt') }
    let(:code_snippet) { Nanoc::CodeSnippet.new(data, filename) }

    it 'should checksum the data' do
      subject.calc(code_snippet).must_equal(subject.calc(data))
    end

  end

  describe 'for Nanoc::Configuration' do

    let(:wrapped)       { { a: 1, b: 2 } }
    let(:configuration) { Nanoc::Configuration.new(wrapped) }

    it 'should checksum the hash' do
      subject.calc(configuration).must_equal(subject.calc(wrapped))
    end

  end

  describe 'for Nanoc::Document' do

    let(:string)          { 'asdf' }
    let(:filename)        { File.expand_path('bob.txt') }
    let(:content)         { Nanoc::TextualContent.new(string, filename) }
    let(:attributes)      { { a: 1, b: 2 } }
    let(:identifier)      { '/foo.md' }
    let(:document)        { Nanoc::Item.new(content, attributes, identifier) }
    let(:normal_checksum) { 'ef8d87a9bd892a740884e2f06149674622bd2763' }

    it 'should checksum document' do
      subject.calc(document).must_equal(normal_checksum)
    end

    describe 'with changed attributes' do

      let(:attributes) { { x: 4, y: 5 } }

      it 'should have a different checksum' do
        subject.calc(document).must_match(CHECKSUM_REGEX)
        subject.calc(document).wont_equal(normal_checksum)
      end

    end

    describe 'with changed content' do

      let(:string) { 'something drastically different' }

      it 'should have a different checksum' do
        subject.calc(document).must_match(CHECKSUM_REGEX)
        subject.calc(document).wont_equal(normal_checksum)
      end

    end

  end

  describe 'for any other classes' do

    let(:unchecksumable_object) { Object.new }

    it 'should raise an exception' do
      assert_raises(Nanoc::Checksummer::UnchecksummableError) do
        subject.calc(unchecksumable_object)
      end
    end

  end

end
