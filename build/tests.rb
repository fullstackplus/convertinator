require 'minitest/spec'
require 'minitest/autorun'
require_relative 'convertinator'

describe "tests for merging markdown files and converting them into HTML" do
  markdown = Convertinator::fileformat('mdown')
  html     = Convertinator::fileformat('html')
  pdf      = Convertinator::fileformat('pdf')

  before do
    File.delete(markdown) if File.exist?(markdown)
    File.delete(html) if File.exist?(html)
    File.delete(pdf) if File.exist?(pdf)
  end

  merged_contents = <<-EOT
#FILE 1

Contents of file one.

#FILE 2

Contents of file two.

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

  it "returns a nested list of files and directories" do
   _(Convertinator::traverse_and_merge(dir, markdown))
   .must_equal [1, 2, 3, 1, 4, 1, 2, 4]
   # .must_equal [1, 2, [3, [1], [4, [1, 2]], 4]]
  end

  it "merges markdown files across nested directories" do
   Convertinator::merge_markdown('..')
   _(File.read(markdown)).must_equal merged_contents
  end

  # it "converts one specified file to HTML and PDF" do
  #  Convertinator::convert_file('../3-dir/1-file.mdown')
  #  htmlfile = Convertinator::output_path('1-file.html')
  #  pdffile  = Convertinator::output_path('1-file.pdf')

  #  _(File.file?(htmlfile)).must_equal true
  #  _(File.file?(pdffile)).must_equal true

  #  # File.delete(htmlfile)
  #  # File.delete(pdffile)
  # end

  it "converts the entire document to HTML and PDF from default directory (root)" do
    Convertinator::convert_dir('..')

    _(File.file?(markdown)).must_equal true
    _(File.file?(html)).must_equal true
    _(File.file?(pdf)).must_equal true
  end
end
