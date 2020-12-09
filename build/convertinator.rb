require 'redcarpet'
require 'pathname'
require 'pry'

# imports Redcarpet functionality as object
RENDERER = Redcarpet::Markdown.new(Redcarpet::Render::HTML, autolink: true, tables: true, footnotes: true)

STARTDIR = File.expand_path("..", Dir.pwd)

module Convertinator
  extend self

  def project_name
    Pathname.new(STARTDIR).basename.to_s
  end

  def fileformat(name)
    File.join(STARTDIR, "#{project_name}.#{name}")
  end

  def abspath(relpath)
    File.join(STARTDIR, relpath)
  end

  def path_to(filename, format)
    name_strings = filename.split('.')[0].split('/').join '_'
    name_string = [project_name, name_strings].join '_'
    File.join(STARTDIR, "#{name_string}.#{format}")
  end

  def buildfile_path(filename)
   File.join(Dir.pwd, 'lib', filename)
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

  def convert_project
    convert_dir(STARTDIR)
  end

  # TODO: testme
  def convert_dir(startdir)
    to_pdf(merge_markdown(startdir))
  end

  def convert_file(relpath)
    to_pdf(abspath(relpath), relpath)
  end

  def to_html(markdown, outputfile="")
    html = RENDERER.render(File.read(markdown))
    file = if outputfile.empty?
     fileformat('html')
    else
     path_to(outputfile, 'html')
    end

    File.open(file, 'w') do |f|
      f.write(File.read(buildfile_path('header.html')))
      # TODO: write tabs for better indentation
      # f.write "\t\t\t"
      f.write html
      f.write(File.read(buildfile_path('footer.html')))
    end
    file
  end

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

