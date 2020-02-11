require 'redcarpet'
require 'pry'

# import renderer object
RENDERER = Redcarpet::Markdown.new(Redcarpet::Render::HTML, autolink: true, tables: true)
OUTPUTDIR = '/build'

# Usage:
# markdown = File.read file
# html = RENDERER.render markdown

# See Desktop/es/workshops/IL/EN/html_renderer.rb for details.

# API:
# Convertinator::traverse_and_print('.')
# Convertinator::merge_markdown('.')
# Convertinator::to_html('.')
module Convertinator

  def self.buildfile_path(filename)
   File.join(Dir.pwd, OUTPUTDIR, 'lib', filename)
  end

  def self.output_path(filename)
   File.join(Dir.pwd, OUTPUTDIR, filename)
  end

  # (str, str) ->
  def self.traverse_and_print(startdir, indent='')
    Dir.foreach(startdir) do |filename|
      path = File.join(startdir, filename)

      if filename == "." or filename == ".."
        next

      elsif File.file?(path)
        puts [indent, filename].join
        next

      else File.directory?(path)
        puts [indent, path, "/"].join
        traverse_and_print(path, [indent, '    '].join)
      end
    end
  end

  # Desired API:
  #
  # def merge_markdown(startdir, output)
  #   self.create_file(startdir, output)
  #   self.traverse_and_merge(startdir, args, output)
  # end
  #
  # Calling:
  #
  # Convertinator::merge_markdown('.', outupt = "merged.mdown")
  #
  # The point is to move the file creation out of the concatenate() method.
  def self.merge_markdown(startdir, outputfile="merged.mdown")
    outputpath = output_path(outputfile)
    self.create_file(outputpath)
    self.traverse_and_merge(startdir, outputpath)
  end

  # (str) -> nil
  def self.create_file(outputpath)
    unless File.file? outputpath
      File.open(outputpath, 'w') { |f| f.write '' }
    end
  end

  # Match at the start of the line: one or more digit,
  # followed by a single dash, followed by any text.
  #
  # (str) -> Regex | nil
  def self.content?(path)
    File.basename(path).match /^[0-9]+\-{1}\w/
  end

  # (str) -> bool
  def self.markdown?(path)
    File.file?(path) &&
    File.extname(path).downcase.eql?('.mdown')
  end

  # if content?
  #   if file?
  #     if markdown?
  #       merge with output file
  #   else if directory?
  #     recur
  #
  # (str, file, depth) -> nil
  def self.traverse_and_merge(startdir, outputpath, indent="", depth=1)

    Dir.foreach(startdir) do |filename|
      path = File.join(startdir, filename)

      if filename == "." or filename == ".."
        next

      elsif content? path
        if markdown? path
            puts [indent, filename].join

            File.open(outputpath, "a") do |f|
              f.write File.read path
              f.write "\n"
            end
          next

        else File.directory?(path)
          puts [indent, path, "/"].join
          traverse_and_merge(path, outputpath, [indent, '    '].join, depth.next)
        end
      end

    end
  end

  def self.convert_dir(startdir, inputfile="merged.mdown", outputfile="file.html")
    merge_markdown(startdir, inputfile)
    input  = output_path(inputfile)
    output = output_path(outputfile)
    to_html(input, output)
  end

  def self.convert_file(inputfile)
    markdown = File.basename inputfile
    filename = markdown.split('.')[0]
    # set name of outputfile to that of inputfile:
    output = output_path("#{filename}.html")
    to_html(inputfile, output)
  end

  def self.to_html(inputfile, outputpath)
    html = RENDERER.render(File.read(inputfile))
    File.open(outputpath, 'w') do |f|
      f.write(File.read(buildfile_path('header.html')))
      f.write html
      f.write(File.read(buildfile_path('footer.html')))
    end
  end
end

require 'minitest/spec'
require 'minitest/autorun'

describe "tests for merging markdown files and converting them into HTML" do
  markdown = Convertinator::output_path('merged.mdown')
  html     = Convertinator::output_path('file.html')
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

                       EOT

  it "merges markdown files across nested directories" do
   Convertinator::merge_markdown('.')
   File.read(markdown).must_equal merged_contents
  end

  it "converts Markdown to HTML from default directory (root)" do
    Convertinator::convert_dir('.')
    File.file?(html).must_equal true
  end

  it "converts Markdown to HTML using custom params for source directory and filenames" do
   Convertinator::convert_dir('underdir', inputfile="foo.mdown", outputfile="bar.html")

   merged_underdir = Convertinator::output_path('foo.mdown')
   File.read(merged_underdir).must_equal merged_contents
   File.delete(merged_underdir)

   converted_underdir = Convertinator::output_path('bar.html')
   File.file?(converted_underdir).must_equal true
   File.delete(converted_underdir)
  end

  it "converts specified file from Markdown to HTML" do
   Convertinator::convert_file('3-dir/1-file.mdown')
   converted_file = Convertinator::output_path('1-file.html')
   File.file?(converted_file).must_equal true
   File.delete(converted_file)
  end
end
