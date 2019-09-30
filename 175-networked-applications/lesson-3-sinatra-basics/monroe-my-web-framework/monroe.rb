class Monroe
  def erb(filename, local = {})
    b = binding
    message = local[:message]

    path = "views/#{filename}.erb"
    content = File.read(path)
    ERB.new(content).result(b)
  end

  def response(status, header, body = '')
    body = yield if block_given?
    [status, header, [body]]
  end
end