# encoding: utf-8

class Nanoc::GemTest < Nanoc::TestCase
  def setup
    super
    FileUtils.cd(@orig_wd)
  end

  def test_build
    require 'systemu'

    # Require clean environment
    Dir['nanoc-core-*.gem'].each { |f| FileUtils.rm(f) }

    # Build
    files_before = Set.new Dir['**/*']
    stdout = ''
    stderr = ''
    status, _ = systemu(
      'gem build nanoc-core.gemspec',
      'stdin'  => '',
      'stdout' => stdout,
      'stderr' => stderr)
    assert status.success?
    files_after = Set.new Dir['**/*']

    # Check new files
    diff = files_after - files_before
    assert_equal 1, diff.size
    assert_equal "nanoc-core-#{Nanoc::VERSION}.gem", diff.to_a[0]
  ensure
    Dir['nanoc-core-*.gem'].each { |f| FileUtils.rm(f) }
  end
end
