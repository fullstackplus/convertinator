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

  # THIS WORX
  # (str) -> bool
  def markdown?(path)
    # File.file?(path) &&
    File.extname(path).downcase.eql?('.mdown')
  end

  # Prototype method for traverse_and_merge. Prints only.
  #
  # (str, str) ->
  # def traverse_and_print(startdir, dirs=[], indent='')
  #   entries = Dir.entries(startdir).sort
  #   content = entries.select { |e| content? e }
  #   paths = content.map { |c| [STARTDIR, c].join '/' }
  #   pathnames = paths.map { |p| Pathname.new p  }
  #   # binding.pry
  #   pathnames.each do |p|
  #     if p.file?
  #       if dirs.empty?
  #         puts indent + p.to_s
  #       else
  #         file = p.split[1].to_s
  #         puts [indent + STARTDIR, dirs, file].join '/'
  #       end
  #     next

  #     else
  #       # Use the API:
  #       # https://ruby-doc.org/stdlib-2.7.1/libdoc/pathname/rdoc/Pathname.html#method-i-to_s
  #       # puts "INSIDE SUBDIR: "+ p.to_s
  #       puts "CHILDREN: "+ p.children.to_s
  #       puts "DIRNAME: "+ p.split[1].to_s

  #       dirs << dirname = p.split[1].to_s
  #       traverse_and_print(p, dirs, [indent, '    '].join)
  #       dirs = dirs.slice(0.. -2)
  #     end
  #   end
  # end


  # FUCKING FINALLY, DUDE.
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

  # Performs a depth-first traversal of the directory tree
  # starting with the specified @startdir, merging .mdown
  # files along the way into @outputpath.
  #
  # @indent: for pretty printing the directory tree
  # @depth : for debugging
  #
  # (str, file, depth) -> nil
  def traverse_and_merge(startdir, outputpath, dirs=[], indent="")
    entries = Dir.entries(startdir).sort
    content = entries.select { |e| content? e }
    paths = content.map { |c| [STARTDIR, c].join '/' }
    pathnames = paths.map { |p| Pathname.new p  }

    binding.pry

    pathnames.each do |p|
      if p.file?

        # if dirs.empty?
        #   path = p.to_s
        # else
        #   path = [p.to_s, dirs].join '/'
        # end

        puts "FILE: "+ p.to_s

        File.open(outputpath, "a") do |f|
          f.write File.read p.to_s
          f.write "\n"
        end
        next

      else
        # Use the API:
        # https://ruby-doc.org/stdlib-2.7.1/libdoc/pathname/rdoc/Pathname.html#method-i-to_s
        puts "INSIDE SUBDIR: "+ p.to_s
        puts "CHILDREN: "+ p.children.to_s
        puts "DIRNAME: "+ p.split[1].to_s
        dirs << p.split[1].to_s
        traverse_and_merge(p, outputpath, dirs, [indent, '    '].join)
        dirs = dirs.slice(0.. -2)
      end
    end
  end

  def merge_markdown(startdir, outputfile="merged.mdown")
    outputpath = output_path(outputfile)
    create_file(outputpath)
    traverse_and_merge(startdir, outputpath)
  end

  def convert_dir(startdir, inputfile="merged.mdown", outputfile="merged.html")
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
