require 'redcarpet'
require 'pathname'
require 'pry'

# imports Redcarpet functionality
RENDERER = Redcarpet::Markdown.new(Redcarpet::Render::HTML, autolink: true, tables: true, footnotes: true)

STARTDIR = File.expand_path("..", Dir.pwd)

# To distinguish between different kinds of paths
# (which in Ruby are all strings), Convertinator
# uses the following naming convention for path
# variables:
#
# 1. 'directory', as in '3-dir'
# 2. 'file' or 'filename', as in 'foo.mdown'
# 3. 'path' (composite), as in '3-dir/foo.mdown'
# 4. 'content' refers to either 1) or 2) above.

module Convertinator
  extend self

  def project_name
    Pathname.new(STARTDIR).basename.to_s
  end

  def fileformat(format)
    File.join(STARTDIR, "#{project_name}.#{format}")
  end

  def abspath(filename)
    File.join(STARTDIR, filename)
  end

  def path_to(filename, format)
    name_strings = filename.split('.')[0].split('/').join '_'
    name_string = [project_name, name_strings].join '_'
    File.join(STARTDIR, "#{name_string}.#{format}")
  end

  def buildfile_path(filename)
   File.join(Dir.pwd, 'lib', filename)
  end

  # Match at the start of line: one or more digit,
  # followed by a single dash, followed by any text.
  #
  # (str) -> Regex | nil
  def content?(filename)
    File.basename(filename).match /^[0-9]+\-{1}\w/
  end

  # Prototype method for traverse_and_merge(); only prints.
  def traverse_and_print(startdir, indent='')
    dir = Pathname.new startdir
    children = dir.children.sort
    content = children.select { |e| content? e }
    content.each do |c|
      if c.file?
        puts indent+c.to_s
      next
      else
        puts indent+c.to_s
        traverse_and_print(c.to_s, [indent, '    '].join)
      end
    end
  end

  def id(content)
    if content.respond_to? 'split'
      (content.split[1].to_s.split('-').first).to_i
    else
      (content.first.split[1].to_s.split('-').first).to_i
    end
  end

  # Performs a depth-first traversal of the directory tree,
  # merging together .mdown files in the order visited.
  #
  # @startdir: where the traversal starts
  # @outputpath: for writing the resultant Markdown file
  # @indent: for pretty printing the directory tree
  # @depth: for debugging
  #
  # (str, file, depth) -> nil
  def traverse_and_merge(startdir, outputpath, indent='', ids=[])
    children = Pathname.new(startdir).children.sort
    content = children.select { |e| content? e }
    content.each do |c|
      ids << id(c)
      if c.file?
        puts indent+c.to_s
        File.open(outputpath, "a") do |f|
          f.write File.read c.to_s
          f.write "\n"
        end
      next

      else
        puts indent+c.to_s
        traverse_and_merge(c.to_s, outputpath, [indent, '    '].join, ids)
      end
    end
    ids
  end

  def merge_markdown(dirname, outputfile="")
    outputpath = if outputfile.empty?
      fileformat('mdown')
    else
      path_to(outputfile, 'mdown')
    end
    traverse_and_merge(dirname, outputpath)
    outputpath
  end

  def convert_project
    convert_dir
  end

  def convert_dir(outputfile="")
    dirpath = outputfile.empty? ? STARTDIR : abspath(outputfile)
    markdown = merge_markdown(dirpath, outputfile)
    to_pdf(markdown, outputfile)
  end

  def convert_file(filename)
    to_pdf(abspath(filename), filename)
  end

  # (str, str)
  def to_html(markdown, outputfile="")
    html = RENDERER.render(File.read(markdown))
    file = if outputfile.empty?
     fileformat('html')
    else
     path_to(outputfile, 'html')
    end

    File.open(file, 'w') do |f|
      f.write(File.read(buildfile_path('header.html')))
      f.write html
      f.write(File.read(buildfile_path('footer.html')))
    end
    file
  end

  # (str, str)
  def to_pdf(markdown, outputfile="")
    html = to_html(markdown, outputfile)
    pdf = if outputfile.empty?
      fileformat('pdf')
    else
      path_to(outputfile, 'pdf')
    end

    Dir.chdir(STARTDIR) {
      system("pandoc --pdf-engine=prince --css=build/lib/css/pdf.css #{html} -o #{pdf}")
    }
  end
end

