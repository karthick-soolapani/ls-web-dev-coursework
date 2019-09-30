require "sinatra"
require "sinatra/reloader" if development?
require "sinatra/content_for"
require "tilt/erubis"

configure do
  enable :sessions
  set :session_secret, 'secret'

  set :erb, :escape_html => true
end

helpers do
  def total_todos_count(list)
    list[:todos].size
  end

  def remaining_todos_count(list)
    list[:todos].count { |todo| !todo[:done] }
  end

  def list_done?(list)
    total_todos_count(list) > 0 && remaining_todos_count(list) == 0
  end

  def list_class(list)
    if list_done?(list)
      "complete"
    elsif total_todos_count(list) == 0
      "empty"
    end
  end

  def todo_class(todo)
    "complete" if todo[:done]
  end

  def sort_lists(lists, &block)
    done_lists, not_done_lists = lists.partition { |list| list_done?(list) }

    not_done_lists.each(&block)
    done_lists.each(&block)
  end

  def sort_todos(todos, &block)
    done_todos, not_done_todos = todos.partition { |todo| todo[:done] }

    not_done_todos.each(&block)
    done_todos.each(&block)
  end
end

# Returns error message if list name is valid or nil.
def error_for_list(list_name)
  if !(1..100).cover?(list_name.size)
    "List name must be between 1 and 100 characters."
  elsif session[:lists].any? { |list| list[:name].casecmp? list_name }
    "List name must be unique."
  end
end

def error_for_todo(todo_name, todos)
  if !(1..100).cover?(todo_name.size)
    "Todo must be between 1 and 100 characters."
  elsif todos.any? { |todo| todo[:name].casecmp? todo_name }
    "Todo must be unique."
  end
end

def redirect_to_lists
  session[:error] = "The specified list was not found."
  redirect "/lists"
end

def redirect_to_list(list_id)
  session[:error] = "The specified todo was not found."
  redirect "/lists/#{list_id}"
end

def next_list_id(lists)
  max = lists.map { |list| list[:list_id] }.max || 0
  max + 1
end

def fetch_list(lists, list_id)
  lists.find { |list| list[:list_id] == list_id }
end

def next_todo_id(todos)
  max = todos.map { |todo| todo[:todo_id] }.max || 0
  max + 1
end

def fetch_todo(todos, todo_id)
  todos.find { |todo| todo[:todo_id] == todo_id }
end

before "/*" do
  session[:lists] ||= []
  parameters = params[:splat].first.split('/')

  @lists    = session[:lists]

  @list_id  = parameters[1]&.to_i
  @list     = fetch_list(@lists, @list_id)  if @list_id
  @todos    = @list[:todos]                 if @list

  @todo_id  = parameters[3]&.to_i
  @todo     = fetch_todo(@todos, @todo_id)  if @todos && @todo_id
end

get "/" do
  redirect "/lists"
end

# View all lists
get "/lists" do
  erb :lists
end

# View new list form
get "/lists/new" do
  erb :new_list
end

# Create a new list
post "/lists" do
  list_name = params[:list_name].strip
  error = error_for_list(list_name)

  if error
    session[:error] = error
    erb :new_list
  else
    list_id = next_list_id(@lists)
    @lists << { list_id: list_id, name: list_name, todos: [] }
    session[:success] = "The list has been created."
    redirect "/lists"
  end
end

# View a single list
get "/lists/:list_id" do
  redirect_to_lists unless @list

  erb :list
end

# View the edit list form
get "/lists/:list_id/edit" do
  redirect_to_lists unless @list

  erb :edit_list
end

# Update a list
post "/lists/:list_id" do
  redirect_to_lists unless @list

  list_name = params[:list_name].strip

  error = error_for_list(list_name) unless @list[:name].casecmp? list_name

  if error
    session[:error] = error
    erb :edit_list
  else
    @list[:name] = list_name
    session[:success] = "The list has been updated."
    redirect "/lists/#{@list_id}"
  end
end

# Delete a list
post "/lists/:list_id/delete" do
  redirect_to_lists unless @list

  @lists.delete(@list)

  return "/lists" if env["HTTP_X_REQUESTED_WITH"] == "XMLHttpRequest"

  session[:success] = "The list has been deleted."
  redirect "/lists"
end

# Add a new todo to a list
post "/lists/:list_id/todos" do
  redirect_to_lists unless @list

  todo_name = params[:todo].strip

  error = error_for_todo(todo_name, @todos)

  if error
    session[:error] = error
    erb :list
  else
    todo_id = next_todo_id(@todos)
    @todos << { todo_id: todo_id, name: todo_name, done: false }
    session[:success] = "The todo was added."
    redirect "/lists/#{@list_id}"
  end
end

# Delete a todo from a list
post "/lists/:list_id/todos/:todo_id/delete" do
  redirect_to_lists unless @list
  redirect_to_list(@list_id) unless @todo

  @todos.delete(@todo)

  return status(204) if env["HTTP_X_REQUESTED_WITH"] == "XMLHttpRequest"

  session[:success] = "The todo has been deleted."
  redirect "/lists/#{@list_id}"
end

# Update todo status
post "/lists/:list_id/todos/:todo_id" do
  redirect_to_lists unless @list
  redirect_to_list(@list_id) unless @todo

  completed = params[:completed]

  case completed
  when "true"
    @todo[:done] = true
    session[:success] = "Todo completed."
  when "false"
    @todo[:done] = false
    session[:success] = "Todo completion reverted."
  end

  redirect "/lists/#{@list_id}"
end

# Mark all todos in a list as done
post "/lists/:list_id/all_done" do
  redirect_to_lists unless @list

  @todos.each { |todo| todo[:done] = true }
  session[:success] = "All Todos completed."

  redirect "/lists/#{@list_id}"
end

not_found do
  erb "<h2>Page not found</h2>", layout: :layout
end
