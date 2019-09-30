require 'sinatra'
require 'sinatra/reloader'
require 'tilt/erubis'

get "/" do
  @files = []

  Dir.glob("**/*", base: "public") do |filename|
    @files << filename if File.file?("public/#{filename}")
  end

  @files = @files.sort_by { |file| File.basename(file).downcase }
  @sort_name = "Sort Descending"
  @sort_path = "/?order=desc"

  if params['order'] == 'desc'
    @files = @files.reverse
    @sort_name = "Sort Ascending"
    @sort_path = "/?order=asc"
  end

  erb :list_files
end
