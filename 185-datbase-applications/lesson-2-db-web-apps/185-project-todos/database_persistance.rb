require 'pg'

class DatabasePersistance

  def initialize(logger)
    @db = if Sinatra::Base.production?
            PG.connect(ENV['DATABASE_URL'])
          else
            PG.connect(dbname: 'todos')
          end

    @logger = logger
  end

  def disconnect
    @db.close
  end

  def query(statement, *params)
    loc = caller_locations(1,1).first
    @logger.info("#{loc.path.split('/').last}:#{loc.lineno} in #{loc.label}")
    @logger.info("SQL STATEMENT: #{statement} | PARAMS: #{params}")
    @db.exec_params(statement, params)
  end

  def associate_todos_with_list(list)
    list.map do |tuple|
      list_id = tuple['id'].to_i
      list_name = tuple['name']

      {id: list_id, name: list_name, todos: all_todos_for_list(list_id)}
    end
  end

  def all_lists
    sql = "SELECT * FROM lists"
    result = query(sql)

    associate_todos_with_list(result)
  end

  def fetch_list(list_id)
    sql = "SELECT * FROM lists WHERE id = $1"
    result = query(sql, list_id)

    associate_todos_with_list(result).first
  end

  def format_todos(todos)
    todos.map do |tuple|
      {id: tuple['id'].to_i, name: tuple['name'], completed: tuple['completed'] == 't'}
    end
  end

  def all_todos_for_list(list_id)
    sql = "SELECT * FROM todos WHERE list_id = $1"
    result = query(sql, list_id)

    format_todos(result)
  end

  def fetch_todo(list_id, todo_id)
    sql = "SELECT * FROM todos WHERE id = $1 AND list_id = $2"
    result = query(sql, todo_id, list_id)

    format_todos(result).first
  end

  def create_new_list(list_name)
    sql = "INSERT INTO lists (name) VALUES ($1)"
    query(sql, list_name)
  end

  def update_list_name(list_id, new_name)
    sql = "UPDATE lists SET name = $2 WHERE id = $1"
    query(sql, list_id, new_name)
  end

  def delete_list(list_id)
    sql = "DELETE FROM lists WHERE id = $1"
    query(sql, list_id)
  end

  def create_new_todo(list_id, todo_name)
    sql = "INSERT INTO todos (list_id, name) VALUES ($1, $2)"
    query(sql, list_id, todo_name)
  end

  def delete_todo(list_id, todo_id)
    sql = "DELETE FROM todos WHERE id = $1 AND list_id = $2"
    query(sql, todo_id, list_id)
  end

  def update_todo_status(list_id, todo_id, new_status)
    sql = "UPDATE todos SET completed = $1 WHERE id = $2 AND list_id = $3"
    query(sql, new_status, todo_id, list_id)
  end

  def mark_all_todos_for_list_as_completed(list_id)
    sql = "UPDATE todos SET completed = true WHERE list_id = $1"
    query(sql, list_id)
  end

end