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
# Convertinator::merge_markdown('.', outupt = "concatenated.mdown")
#
# The point is to move the file creation out of the concatenate() method.
def self.merge_markdown(startdir, outputfile="concatenated.mdown")
  self.create_file(startdir, outputfile)
  self.traverse_and_merge(startdir, outputfile)
end

  # TESTME
  # (str) -> bool
  def self.markdown?(path)
    File.file?(path) &&
    File.extname(path).downcase.eql?('.mdown')
  end

  # (str, str) -> nil
  def self.create_file(startdir, outputfile)
    # path = File.join(Dir.pwd, outputfile)
    path = File.join(startdir, outputfile)
    unless File.file? path
      File.open(path, 'w') { |f| f.write '' }
    end
  end

  # if file
  #   concatenate
  # recursively continue traversal
  #
  # (str, file, depth) -> nil
  def self.traverse_and_merge(startdir, outputfile, indent="", depth=1)

    # binding.pry

    Dir.foreach(startdir) do |filename|
      path = File.join(startdir, filename)

      if filename == "." or filename == ".."
        next

      # concatenate files here
      elsif File.file?(path)
        if File.extname(path).downcase.eql?('.mdown')
          puts [indent, filename].join
        end
        next

      else File.directory?(path)
        puts [indent, path, "/"].join
        traverse_and_merge(path, outputfile, [indent, '    '].join, depth.next)
      end
    end
  end
end

require 'minitest/spec'
require 'minitest/autorun'

describe "tests for merging markdown files and converting them into HTML" do
  path = File.join(Dir.pwd, "concatenated.mdown")
  before do
    File.delete(path) if File.exist?(path)
  end

  it "merges markdown files across nested directories" do

   # TODO:
   # 1) don't overwrite the output file with itself
   # 2) don't traverse Git directories.
   #
   Convertinator::merge_markdown('.')
   # file_contents = File.open(path).read
   #
   # TODO:
   # file_contents.must_equal contents of a local file (EOS, EOA etc).
  end
end
