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

# TODO move this elsewhere
class Nanoc::FilesystemPrunerTest < Nanoc::TestCase

  def test_find_compiled_files
    in_site do
      FileUtils.mkdir_p('output/some/random/directories/here')
      File.write('output/some/random/file.txt', 'blah')
      File.write('output/index.html', 'yay')

      pruner = Nanoc::FilesystemPruner.new(site_here)
      files = pruner.find_compiled_files

      assert_equal files, []
    end
  end

  def test_find_present_files_and_dirs
    in_site do
      FileUtils.mkdir_p('output/some/random/dir')
      File.write('output/some/random/file.txt', 'blah')
      File.write('output/index.html', 'yay')

      pruner = Nanoc::FilesystemPruner.new(site_here)
      files, dirs = pruner.find_present_files_and_dirs

      expected_files = [
        'output/index.html',
        'output/some/random/file.txt',
      ]

      expected_dirs = [
        'output/',
        'output/some',
        'output/some/random',
        'output/some/random/dir',
      ]

      assert_set_equal files, expected_files
      assert_set_equal dirs,  expected_dirs
    end
  end

  def test_remove_stray_files_and_dirs
    in_site do
      FileUtils.mkdir_p('output/some/random/dir')
      File.write('output/some/random/file.txt', 'blah')
      File.write('output/index.html', 'yay')

      refute_equal Dir['output/**/*'], []

      pruner = Nanoc::FilesystemPruner.new(site_here)
      pruner.run

      assert_equal Dir['output/**/*'], []
    end
  end

  def test_exclude
    in_site do
      FileUtils.mkdir_p('output/some/random/dir')
      FileUtils.mkdir_p('output/another/random/dir')
      File.write('output/some/random/file.txt',    'blah')
      File.write('output/another/random/file.txt', 'blah')
      File.write('output/another/some',            'blah')

      assert File.file?('output/some/random/file.txt')
      assert File.file?('output/another/random/file.txt')
      assert File.file?('output/another/some')

      pruner = Nanoc::FilesystemPruner.new(site_here, exclude: [ 'some' ])
      pruner.run

      assert File.file?('output/some/random/file.txt')
      refute File.file?('output/another/random/file.txt')
      assert File.file?('output/another/some')
    end
  end

end
