def parse_request(request_line)
  http_method, path_and_params, scheme = request_line.split
  path, params = path_and_params.split('?')
  params ||= ''
  params = params.split('&').map { |param| param.split('=') }.to_h

  [http_method, path, params]
end