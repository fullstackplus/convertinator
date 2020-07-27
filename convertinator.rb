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
  def traverse_and_print(startdir, dirs=[], indent='')
    dirs << startdir if dirs.empty?
    entries = Dir.entries(startdir).sort
    gizzez = entries.reject { |e| e == "." or e == ".." }

    gizzez.each do |filename|
      if File.file?(filename)
        # puts [indent, filename].join
        path = [Dir.getwd, dirs, filename].join '/'
        puts path
        next

      elsif File.directory?(filename)
        # puts [indent, filename, "/"].join
        dirs << filename
        traverse_and_print(filename, dirs, [indent, '    '].join)
        dirs = dirs.slice(0.. -2)
      end
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
  def traverse_and_merge(startdir, outputpath, dirs=[], indent="")
    # dirs << startdir if dirs.empty?
    entries = Dir.entries(startdir).sort
    gizzez = entries.reject { |e| e == "." or e == ".." }

    # binding.pry

    gizzez.each do |filename|
      if markdown? filename
        if dirs.empty?
          path = [Dir.getwd, filename].join '/'
        else
          path = [Dir.getwd, dirs, filename].join '/'
        end

        # puts [indent, filename].join
        puts [indent, path].join

        File.open(outputpath, "a") do |f|
          f.write File.read path
          f.write "\n"
        end
        next

      elsif File.directory?(filename)
        # puts [indent, filename, "/"].join
        dirs << filename
        traverse_and_merge(filename, outputpath, dirs, [indent, '    '].join)
        dirs = dirs.slice(0.. -2)
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

# puts arr
# puts also
# puts "WD: "               +Dir.getwd
# puts [indent, filename].join
# puts "EXPANDED filename: " +File.expand_path(filename)
# # puts "EXPANDED __FILE__: " +File.expand_path(__FILE__)
# puts "DIRNAME: "           +File.dirname(filename)
# puts "BASENAME: "          +File.basename(filename)
# puts "PWD: "               +Dir.pwd

# puts "JOINED: "            +[startdir, '/', filename].join
# puts
