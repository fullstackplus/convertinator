require 'minitest/spec'
require 'minitest/autorun'
require_relative 'convertinator'

describe "tests for merging markdown files and converting them into HTML" do
  markdown = Convertinator::output_path('merged.mdown')
  html     = Convertinator::output_path('merged.html')

  before do
    File.delete(markdown) if File.exist?(markdown)
    File.delete(html) if File.exist?(html)
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

  it "converts Markdown to HTML from default directory (root)" do
    Convertinator::convert_dir('..')
    _(File.file?(html)).must_equal true
  end

  it "converts Markdown to HTML using custom params for source directory and filenames" do
   Convertinator::convert_dir('..', inputfile="foo.mdown", outputfile="bar.html")

   merged = Convertinator::output_path('foo.mdown')
   _(File.read(merged)).must_equal merged_contents
   File.delete(merged)

   converted = Convertinator::output_path('bar.html')
   _(File.file?(converted)).must_equal true
   File.delete(converted)
  end

  it "converts specified file from Markdown to HTML" do
   Convertinator::convert_file('../3-dir/1-file.mdown')
   converted = Convertinator::output_path('1-file.html')
   _(File.file?(converted)).must_equal true
   File.delete(converted)
  end
end
