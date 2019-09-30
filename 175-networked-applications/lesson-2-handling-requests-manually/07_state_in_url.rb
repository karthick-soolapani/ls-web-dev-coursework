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
  
  request_line = client.gets
  next if !request_line || request_line =~ /favicon/
  puts "Done"

  http_method, path, params = parse_request(request_line)
  number = params["number"].to_i

  html_response = <<~HTML
  <!DOCTYPE html>
  <html>

    <head>
      <style type="text/css">
        .btn a {
          border: 2px solid lightblue;
          border-radius: 10%;
          margin: 5px 5px 5px 0px;
          padding: 5px;
          background-color: lightblue;
        }
      </style>
    </head>

    <body>
      <p>Request Line : #{request_line}<br>Request Method : #{http_method}<br>Request Path : #{path}<br>Request Params : #{params}</p>

      <h3 style="color: maroon">Counter</h3>
      <p style="color: blue">Current number is #{number}</p>

      <div class="btn">
        <a href="?number=#{number - 1}">Subtract one</a>
        <a href="?number=#{number + 1}">Add one</a>
      </div>
    </body>

  </html>
  HTML

  client.puts "HTTP/1.1 200 OK"
  client.puts "Content-Type: text/html"
  client.puts nil
  client.puts html_response

  client.close
end
