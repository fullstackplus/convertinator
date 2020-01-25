require 'redcarpet'
require 'pry'

# import renderer object
RENDERER = Redcarpet::Markdown.new(Redcarpet::Render::HTML, autolink: true, tables: true)

# Usage:
# markdown = File.read file
# html = RENDERER.render markdown

# See Desktop/es/workshops/IL/EN/html_renderer.rb for details.

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

  # (str) -> bool
  def self.markdown?(path)
    File.file?(path) &&
    File.extname(path).downcase.eql?('.mdown')
  end

  # (str, str) -> nil
  def self.create_file(filename)
    path = File.join(Dir.pwd, filename)
    # path = File.join(startdir, filename)
    unless File.file? path
      File.open(path, 'w') { |f| f.write '' }
    end
  end

  # if file
  #   concatenate
  # recursively continue traversal
  #
  # (str, file, depth) -> file
  def self.concatenate(startdir, indent="", depth=1)

    binding.pry

    Dir.foreach(startdir) do |filename|
      path = File.join(startdir, filename)

      if filename == "." or filename == ".."
        next

      elsif File.file?(path)
        if File.extname(path).downcase.eql?('.mdown')
          puts [indent, filename].join
        end
        next

      else File.directory?(path)
        puts [indent, path, "/"].join
        concatenate(path, [indent, '    '].join, depth.next)
      end
    end
  end
end

# Convertinator::traverse_and_print('.')
Convertinator::concatenate('.')


require 'minitest/spec'
require 'minitest/autorun'

describe "tests" do
  path = File.join(Dir.pwd, "concatenated.mdown")
  before do
    File.delete(path) if File.exist?(path)
  end

  it "passes all tests" do
   contents = 'Contents of file one. Contents of file two. Contents of file three.'

   # TODO: function must return a file
   # Convertinator::concatenate('.')

   # binding.pry

   # file_contents = File.open(path).read

   #TODO: recursive call doesn't work
   # file_contents.must_equal contents
  end
end
