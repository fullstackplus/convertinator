require 'redcarpet'
require 'pry'

# imports Redcarpet functionality as object
RENDERER = Redcarpet::Markdown.new(Redcarpet::Render::HTML, autolink: true, tables: true)

# output directory is a 'sensible default' but can  be overrriden here:
OUTPUTDIR = '/build'

module Convertinator
  extend self

  def output_path(filename)
   File.join(Dir.pwd, OUTPUTDIR, filename)
  end

  def buildfile_path(filename)
   File.join(Dir.pwd, OUTPUTDIR, 'lib', filename)
  end

  # (str) -> nil
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

  # (str) -> bool
  def markdown?(path)
    File.file?(path) &&
    File.extname(path).downcase.eql?('.mdown')
  end

  # Prototype method for traverse_and_merge. Prints only.
  #
  # (str, str) ->
  def traverse_and_print(startdir, indent='')
    entries = Dir.entries(startdir).sort
    entries.each do |filename|
      next if filename == "." or filename == ".."

      if File.file?(filename)
        puts [indent, filename].join
        next

      else File.directory?(filename)
        puts [indent, filename, "/"].join
        traverse_and_print(filename, [indent, '    '].join)
      end
    end
  end


  def visit(startdir, indent='')
     puts Dir.entries(startdir).sort
     puts "HA"
     puts Dir.glob("*.mdown").sort
     puts "HAHA"
     puts Dir.glob("underdir").sort
  end


  # Performs a depth-first traversal of the directory tree
  # starting with the specified @startdir, merging .mdown
  # files along the way into @outputpath.
  #
  # @indent: for pretty printing the directory tree
  # @depth : for debugging
  #
  # (str, file, depth) -> nil
  def traverse_and_merge(startdir, outputpath, indent="", depth=1)
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

  def merge_markdown(startdir, outputfile="merged.mdown")
    outputpath = output_path(outputfile)
    create_file(outputpath)
    traverse_and_merge(startdir, outputpath)
  end

  def convert_dir(startdir, inputfile="merged.mdown", outputfile="file.html")
    merge_markdown(startdir, inputfile)
    input  = output_path(inputfile)
    output = output_path(outputfile)
    to_html(input, output)
  end

  def convert_file(inputfile)
    markdown = File.basename inputfile
    filename = markdown.split('.')[0]
    # set name of outputfile to that of inputfile:
    output = output_path("#{filename}.html")
    to_html(inputfile, output)
  end

  def to_html(inputfile, outputpath)
    html = RENDERER.render(File.read(inputfile))
    File.open(outputpath, 'w') do |f|
      f.write(File.read(buildfile_path('header.html')))
      f.write html
      f.write(File.read(buildfile_path('footer.html')))
    end
  end
end
