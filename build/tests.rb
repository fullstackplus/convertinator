require 'minitest/spec'
require 'minitest/autorun'
require_relative 'convertinator'

def file_created? file
  Dir.chdir(STARTDIR) { File.file? file }
end

describe "tests for merging markdown files and converting them into HTML" do
  # single file
  html_file = 'convertinator_3-dir_1-file.html'
  pdf_file  = 'convertinator_3-dir_1-file.pdf'

  # specified dir
  markdown_dir = 'convertinator_3-dir.mdown'
  html_dir     = 'convertinator_3-dir.html'
  pdf_dir      = 'convertinator_3-dir.pdf'

  # entire project
  markdown = Convertinator::fileformat('mdown')
  html     = Convertinator::fileformat('html')
  pdf      = Convertinator::fileformat('pdf')

  # cleanup
  after do
    Dir.chdir(STARTDIR) do
      File.delete(markdown) if File.exist? markdown
      File.delete(html) if File.exist? html
      File.delete(pdf) if File.exist? pdf

      File.delete(html_file) if File.exist? html_file
      File.delete(pdf_file) if File.exist? pdf_file
    end
  end

  merged_contents = <<-EOT
#FILE 1

Contents of file one.

#FILE 2

Contents of file two.

![Autumn leaves](img/autumn-leaves.jpg "Autumn leaves")

#FILE 3

Contents of file three.

#FILE 4

Contents of file four.

#FILE 5

Contents of file five.

#FILE 6

Contents of file six.

EOT


  dir = File.expand_path("..", Dir.pwd)
  Convertinator.traverse_and_print dir

  it "returns a list of files and directories, in the order visited" do
   _(Convertinator::traverse_and_merge(dir, markdown))
   .must_equal [1, 2, 3, 1, 4, 1, 2, 4]
   # .must_equal [1, 2, [3, [1], [4, [1, 2]], 4]]
  end

  it "merges Markdown files across nested directories" do
   Convertinator::merge_markdown('..')
   _(File.read(markdown)).must_equal merged_contents
  end

  it "converts specified Markdown file to all formats" do
   Convertinator::convert_file('3-dir/1-file.mdown')

   _(file_created?(html_file)).must_equal true
   _(file_created?(pdf_file)).must_equal true
  end

  # TODO: creates .mdown with project name
  it "converts specified directory to all formats" do
    Convertinator::convert_dir('3-dir')

    # _(file_created?(markdown_dir)).must_equal true
    _(file_created?(html_dir)).must_equal true
    _(file_created?(pdf_dir)).must_equal true
  end

  it "converts the entire project starting from root directory" do
    Convertinator::convert_project

    _(file_created?(markdown)).must_equal true
    _(file_created?(html)).must_equal true
    _(file_created?(pdf)).must_equal true
  end
end
