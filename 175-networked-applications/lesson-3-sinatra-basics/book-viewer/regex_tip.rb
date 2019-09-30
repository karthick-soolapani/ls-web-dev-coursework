def assemble_chapter_regex(regex_string, index, magnitude, book_size)
  regex_string << "[1-9]"                       if index == 0
  regex_string << "#{index}" * index            if index.between?(1, magnitude - 1)
  regex_string << "[0-9]" * index               if index.between?(1, magnitude - 2)
  regex_string << "[0 - #{book_size.to_s[-1]}]" if index == magnitude - 1
  regex_string << "(?![0-9]{#{index + 1},})"    if index <= magnitude - 1
  regex_string << '|'                           if index.between?(0, index - 2)
  regex_string
end

def chapter_number_regex
   book_size = read_in_chapters.size
   magnitude = book_size.to_s.size
   regex_string = ""
   magnitude.times do |index|
     assemble_chapter_regex(regex_string, index, magnitude, book_size)
   end
   regex_string
end

get %r{/chapters/(?<number>#{chapter_number_regex})} do
  @content_subhead = "Chapter #{params[:number]}"
  @title = @contents[params[:number].to_i - 1]
  @chapter = File.read("data/chp#{params[:number]}.txt")
  erb :chapter
end