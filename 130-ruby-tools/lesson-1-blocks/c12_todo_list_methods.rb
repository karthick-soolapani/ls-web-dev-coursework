class Todo
  DONE_MARKER = 'X'
  UNDONE_MARKER = ' '

  attr_accessor :title, :description, :done

  def initialize(title, description='')
    @title = title
    @description = description
    @done = false
  end

  def done!
    self.done = true
  end

  def done?
    done
  end

  def undone!
    self.done = false
  end

  def to_s
    "[#{done? ? DONE_MARKER : UNDONE_MARKER}] #{title}"
  end
end

class TodoList
  attr_accessor :title

  def initialize(title)
    @title = title
    @todos = []
  end

  def add(todo)
    raise TypeError.new("Can only add Todo objects") unless todo.instance_of?(Todo)
    @todos << todo
  end
  
  alias << add
  
  def size
    @todos.size
  end
  
  def first
    @todos.first
  end
  
  def last
    @todos.last
  end
  
  def to_a
    @todos.clone
  end
  
  def done?
    @todos.all?(&:done?)
  end
  
  def item_at(index)
    @todos.fetch(index)
  end
  
  def mark_done_at(index)
    item_at(index).done!
  end
  
  def mark_undone_at(index)
    item_at(index).undone!
  end
  
  def done!
    @todos.each(&:done!)
  end
  
  def shift
    @todos.shift
  end
  
  def pop
    @todos.pop
  end
  
  def remove_at(index)
    @todos.delete(item_at(index))
  end
  
  def each
    @todos.each do |todo|
      yield(todo)
    end
    self
  end
  
  def select
    selection = TodoList.new("Filtered Todos")

    each do |todo|
      selection << todo if yield(todo)
    end
    
    selection
  end
  
  def reject
    select { |todo| !yield(todo) }
  end
  
  def find_by_title(title)
    select { |todo| todo.title == title }.first
  end
  
  def all_done
    select(&:done?)
  end
  
  def all_not_done
    reject(&:done?)
  end
  
  def mark_done(title)
    find_by_title(title) && find_by_title(title).done!
  end
  
  def mark_all_done
    each(&:done!)
  end
  
  def mark_all_undone
    each(&:undone!)
  end
  
  def to_s
    (["--- #{title} ---"] + @todos).join("\n")
  end
end

todo1 = Todo.new("Buy milk")
todo2 = Todo.new("Clean room")
todo3 = Todo.new("Go to gym")
list = TodoList.new("Today's Todos")

list.add(todo1)
list.add(todo2)
list.add(todo3)

list.mark_done_at(0)
