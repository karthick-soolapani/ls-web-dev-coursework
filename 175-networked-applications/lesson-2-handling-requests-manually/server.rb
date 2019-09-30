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

  puts client.readpartial(100)

  client.puts "HTTP/1.1 200 OK"
  client.puts "Content-Type: text/plain"
  client.puts nil
  client.puts "Cool"

  client.close
end
