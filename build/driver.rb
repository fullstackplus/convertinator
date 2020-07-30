require_relative 'convertinator'

dir = File.expand_path("..", Dir.pwd)
Convertinator::convert_dir dir
