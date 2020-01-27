require 'redcarpet'
require 'pry'

# import renderer object
RENDERER = Redcarpet::Markdown.new(Redcarpet::Render::HTML, autolink: true, tables: true)

# Usage:
# markdown = File.read file
# html = RENDERER.render markdown

# See Desktop/es/workshops/IL/EN/html_renderer.rb for details.

# API:
# Convertinator::traverse_and_print('.')
# Convertinator::merge_markdown('.')
# Convertinator::to_html('.')
module Convertinator

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
    self.create_file(startdir, outputfile)
    self.traverse_and_merge(startdir, outputfile)
  end

  # (str, str) -> nil
  def self.create_file(startdir, outputfile)
    # path = File.join(Dir.pwd, outputfile)
    path = File.join(startdir, outputfile)
    unless File.file? path
      File.open(path, 'w') { |f| f.write '' }
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

  #
  # if content?
  #   if file?
  #     if markdown?
  #       merge with output file
  #   else if directory?
  #     recur
  #
  # (str, file, depth) -> nil
  def self.traverse_and_merge(startdir, outputfile, indent="", depth=1)

    Dir.foreach(startdir) do |filename|
      path = File.join(startdir, filename)

      if filename == "." or filename == ".."
        next

      elsif content? path
        if markdown? path
            puts [indent, filename].join

            File.open(outputfile, "a") do |f|
              f.write File.open(path).read
              f.write "\n"
            end
          next

        else File.directory?(path)
          puts [indent, path, "/"].join
          traverse_and_merge(path, outputfile, [indent, '    '].join, depth.next)
        end
      end

    end
  end

  # TODO
  def self.to_html(startdir, inputfile="merged.mdown", outputfile="file.html")
    merge_markdown(startdir, inputfile)

    input_path = File.join(startdir, inputfile)
    output_path = File.join(startdir, outputfile)

    html = RENDERER.render(File.read(input_path))
    File.open(output_path, 'w') do |f|
      # f.write File.read 'header.html'
      f.write html
      # f.write File.read 'footer.html'
    end
  end
end

require 'minitest/spec'
require 'minitest/autorun'

describe "tests for merging markdown files and converting them into HTML" do
  path = File.join(Dir.pwd, "merged.mdown")
  before do
    File.delete(path) if File.exist?(path)
  end

  it "merges markdown files across nested directories" do
   Convertinator::merge_markdown('.')
   file_contents = File.open(path).read
   file_contents.must_equal <<-EOT
#FILE 1

Contents of file one.

#FILE 2

Contents of file two.

#FILE 3

Contents of file three.

#FILE 4

Contents of file four.

                               EOT
  end

  it "converts Markdown to HTML" do
    # TODO: test file exists
    Convertinator::to_html('.')
  end
end
