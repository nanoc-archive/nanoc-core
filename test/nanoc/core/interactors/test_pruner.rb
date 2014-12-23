# encoding: utf-8

class Nanoc::PrunerTest < Nanoc::TestCase
  def test_abstract
    in_site do
      pruner = Nanoc::Pruner.new(site_here)

      assert_raises(NotImplementedError) do
        pruner.run
      end
    end
  end
end

# TODO: move this elsewhere
class Nanoc::FilesystemPrunerTest < Nanoc::TestCase
  def test_find_compiled_files
    in_site do
      FileUtils.mkdir_p('build/some/random/directories/here')
      File.write('build/some/random/file.txt', 'blah')
      File.write('build/index.html', 'yay')

      pruner = Nanoc::FilesystemPruner.new(site_here)
      files = pruner.find_compiled_files

      assert_equal files, []
    end
  end

  def test_find_present_files_and_dirs
    in_site do
      FileUtils.mkdir_p('build/some/random/dir')
      File.write('build/some/random/file.txt', 'blah')
      File.write('build/index.html', 'yay')

      pruner = Nanoc::FilesystemPruner.new(site_here)
      files, dirs = pruner.find_present_files_and_dirs

      expected_files = [
        'build/index.html',
        'build/some/random/file.txt',
      ]

      expected_dirs = [
        'build/',
        'build/some',
        'build/some/random',
        'build/some/random/dir',
      ]

      assert_set_equal files, expected_files
      assert_set_equal dirs,  expected_dirs
    end
  end

  def test_remove_stray_files_and_dirs
    in_site do
      FileUtils.mkdir_p('build/some/random/dir')
      File.write('build/some/random/file.txt', 'blah')
      File.write('build/index.html', 'yay')

      refute_equal Dir['build/**/*'], []

      pruner = Nanoc::FilesystemPruner.new(site_here)
      pruner.run

      assert_equal Dir['build/**/*'], []
    end
  end

  def test_exclude
    in_site do
      FileUtils.mkdir_p('build/some/random/dir')
      FileUtils.mkdir_p('build/another/random/dir')
      File.write('build/some/random/file.txt',    'blah')
      File.write('build/another/random/file.txt', 'blah')
      File.write('build/another/some',            'blah')

      assert File.file?('build/some/random/file.txt')
      assert File.file?('build/another/random/file.txt')
      assert File.file?('build/another/some')

      pruner = Nanoc::FilesystemPruner.new(site_here, exclude: ['some'])
      pruner.run

      assert File.file?('build/some/random/file.txt')
      refute File.file?('build/another/random/file.txt')
      assert File.file?('build/another/some')
    end
  end
end
