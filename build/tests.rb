require 'minitest/spec'
require 'minitest/autorun'
require_relative 'convertinator'

describe "tests for merging markdown files and converting them into HTML" do
  # entire document
  markdown = Convertinator::fileformat('mdown')
  html     = Convertinator::fileformat('html')
  pdf      = Convertinator::fileformat('pdf')

  # a single file
  html_file = 'convertinator_3-dir_1-file.html'
  pdf_file  = 'convertinator_3-dir_1-file.pdf'

  after do
    File.delete(markdown) if File.exist? markdown
    File.delete(html) if File.exist? html
    File.delete(pdf) if File.exist? pdf

    File.delete(html_file) if File.exist? html_file
    File.delete(pdf_file) if File.exist? pdf_file
  end

  merged_contents = <<-EOT
#FILE 1

Contents of file one.

#FILE 2

Contents of file two.

<img src="img/autumn-leaves.jpg" alt="Autumn leaves" />

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

  it "returns a list of files and directories, in the order it visits them" do
   _(Convertinator::traverse_and_merge(dir, markdown))
   .must_equal [1, 2, 3, 1, 4, 1, 2, 4]
   # .must_equal [1, 2, [3, [1], [4, [1, 2]], 4]]
  end

  it "merges Markdown files across nested directories" do
   Convertinator::merge_markdown('..')
   _(File.read(markdown)).must_equal merged_contents
  end

  it "converts specified Markdown file to HTML and PDF" do
   Convertinator::convert_file('3-dir/1-file.mdown')

   _(File.file?(html_file)).must_equal true
   _(File.file?(pdf_file)).must_equal true
  end

  it "converts the entire Markdown document to HTML and PDF from default directory (root)" do
    Convertinator::convert_dir('..')

    _(File.file?(markdown)).must_equal true
    _(File.file?(html)).must_equal true
    _(File.file?(pdf)).must_equal true
  end
end
