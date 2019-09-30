$stdout.sync = true # To display output immediately on windows using git bash

require 'socket'

def parse_request(request_line)
  http_method, path_and_params, scheme = request_line.split
  path, params = path_and_params.split('?')
  params = params.split('&').map { |param| param.split('=') }.to_h if params

  [http_method, path, params]
end

server = TCPServer.new("localhost", 3003)

loop do
  client = server.accept
  
  request_line = client.gets
  next if !request_line || request_line =~ /favicon/
  puts "Done"

  http_method, path, params = parse_request(request_line)

  rolls = params&.fetch("rolls", 1)&.to_i || 1
  sides = params&.fetch("sides", 6)&.to_i || 6

  result = []
  rolls.times { result << rand(1..sides) }
  result = result.join(" ")

  html_response = <<~HTML
  <!DOCTYPE html>
  <html>

    <head></head>

    <body>
      <p>Request Line: #{request_line}<br>Request Method: #{http_method}<br>Request Path: #{path}<br>Request Params: #{params}</p>

      <h3 style="color: maroon">Rolls!</h3>
      <p style="color: blue; font-size: 80%">#{result}</p>
    </body>

  </html>
  HTML

  client.puts "HTTP/1.1 200 OK"
  client.puts "Content-Type: text/html"
  client.puts nil
  client.puts html_response

  client.close
end
