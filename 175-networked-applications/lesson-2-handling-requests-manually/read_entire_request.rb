$stdout.sync = true # To display output immediately on windows using git bash

require 'socket'

def parse_request(request_line)
  http_method, path_and_params, scheme = request_line.split
  path, params = path_and_params.split('?')
  params ||= ''
  params = params.split('&').map { |param| param.split('=') }.to_h

  [http_method, path, params]
end

server = TCPServer.new("localhost", 3003)

loop do
  client = server.accept

  request = ''
  content_length = nil
  body = ''

  loop do
    line = client.gets
    request << line  

    content_length = line.split(": ")[1].to_i if line.include?("Content-Length")

    if line == "\r\n"
      body = client.readpartial(content_length) if request.include?("Content-Length")
      break
    end
  end

  puts request
  puts body unless body.empty?

  client.puts "HTTP/1.1 200 OK"
  client.puts "Content-Type: text/plain"
  client.puts nil
  client.puts "Cool"

  client.close
end
