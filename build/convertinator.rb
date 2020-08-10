require 'redcarpet'
require 'pathname'
require 'pry'

# imports Redcarpet functionality as object
RENDERER = Redcarpet::Markdown.new(Redcarpet::Render::HTML, autolink: true, tables: true)

STARTDIR = File.expand_path("..", Dir.pwd)

# output directory is a 'sensible default' but can  be overrriden here:
OUTPUTDIR = ''

module Convertinator
  extend self

  def fileformat(name)
    basename = Pathname.new(STARTDIR).basename.to_s
    File.join(Dir.pwd, "#{basename}.#{name}")
  end

  # DEPRECATE ME
  def output_path(filename)
   File.join(Dir.pwd, OUTPUTDIR, filename)
  end

  def buildfile_path(filename)
   File.join(Dir.pwd, OUTPUTDIR, 'lib', filename)
  end

  # DEPRECATED
  def create_file(outputpath)
    unless File.file? outputpath
      File.open(outputpath, 'w') { |f| f.write '' }
    end
  end

  # Match at the start of the line: one or more digit,
  # followed by a single dash, followed by any text.
  #
  # (str) -> Regex | nil
  def content?(path)
    File.basename(path).match /^[0-9]+\-{1}\w/
  end

  # Protoptype method. Traverses and prints only.
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

  # Performs a depth-first traversal of the directory tree
  # starting with the specified @startdir, merging .mdown
  # files along the way into @outputpath.
  #
  # @indent: for pretty printing the directory tree
  # @depth : for debugging
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

  def merge_markdown(startdir)
    markdown = fileformat('mdown')
    traverse_and_merge(startdir, markdown)
    markdown
  end

  def convert_dir(startdir)
    to_pdf(merge_markdown(startdir))
  end

  # TODO: ALSO AS PDF
  def convert_file(inputfile)
    markdown = File.basename inputfile
    filename = markdown.split('.')[0]
    to_pdf(markdown)
  end

  def to_html(markdown)
    html = RENDERER.render(File.read(markdown))
    file = fileformat('html')

    File.open(file, 'w') do |f|
      f.write(File.read(buildfile_path('header.html')))
      f.write html
      f.write(File.read(buildfile_path('footer.html')))
    end
    file
  end

  # TODO: TESTME
  def to_pdf(markdown)
    html = to_html(markdown)
    pdf  = fileformat('pdf')
    system("pandoc --pdf-engine=prince --css=lib/css/print.css #{html} -o #{pdf}")
  end
end

