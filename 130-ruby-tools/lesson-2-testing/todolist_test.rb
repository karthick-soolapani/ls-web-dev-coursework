require 'simplecov'
SimpleCov.start

require 'minitest/autorun'
require 'minitest/reporters'
Minitest::Reporters.use!

require_relative 'todolist'

class TodoListTest < Minitest::Test
  def setup
    @todo1 = Todo.new("Buy milk")
    @todo2 = Todo.new("Clean room")
    @todo3 = Todo.new("Go to gym")
    @todo4 = Todo.new('Buy battery')
    @todos = [@todo1, @todo2, @todo3]

    @list = TodoList.new("Today's Todos")
    @list.add(@todo1)
    @list.add(@todo2)
    @list.add(@todo3)
  end
  
  def test_to_a
    assert_equal(@todos, @list.to_a)
  end
  
  def test_size
    assert_equal(3, @list.size)
  end
  
  def test_first
    assert_equal(@todo1, @list.first)
  end
  
  def test_last
    assert_equal(@todo3, @list.last)
  end
  
  def test_shift
    assert_equal(@todo1, @list.shift)
    assert_equal([@todo2, @todo3], @list.to_a)
  end
  
  def test_pop
    assert_equal(@todo3, @list.pop)
    assert_equal([@todo1, @todo2], @list.to_a)
  end
  
  def test_done_question
    assert_equal(false, @list.done?)
    
    @todo1.done!
    @todo2.done!
    @todo3.done!
    
    assert_equal(true, @list.done?)
  end
  
  def test_add_raise_error
    assert_raises(TypeError) { @list.add(5) }
    assert_raises(TypeError) { @list.add('Buy carrot') }
  end
  
  def test_shovel
    @list << @todo4
    @todos << @todo4

    assert_equal(@todos, @list.to_a)
  end
  
  def test_add_alias_shovel
    @list_copy = @list.clone
    @list.add(@todo4)
    @list_copy << @todo4

    assert_equal(@list.to_a, @list_copy.to_a)
  end
  
  def test_item_at
    assert_raises(IndexError) { @list.item_at(-4) }
    assert_equal(@todo2, @list.item_at(1))
  end
  
  def test_mark_done_at
    assert_raises(IndexError) { @list.mark_done_at(3) }
    
    @list.mark_done_at(0)
    assert_equal(true, @todo1.done?)
    assert_equal(false, @todo2.done?)
    assert_equal(false, @todo3.done?)
  end
  
  def test_mark_undone_at
    assert_raises(IndexError) { @list.mark_undone_at(3) }

    @todo1.done!
    @todo2.done!
    @todo3.done!

    @list.mark_undone_at(0)
    
    assert_equal(false, @todo1.done?)
    assert_equal(true, @todo2.done?)
    assert_equal(true, @todo3.done?)
  end
  
  def test_done_bang
    @list.done!
    assert_equal(true, @list.done?)
  end
  
  def test_remove_at
    assert_raises(IndexError) { @list.remove_at(3) }
    
    assert_equal(@todo2, @list.remove_at(1))
    assert_equal([@todo1, @todo3], @list.to_a)
  end
  
  def test_to_s
    string = <<-STRING.chomp.gsub(/^\s+/, '') # <<~STRING.chomp will work
    --- Today's Todos ---
    [ ] Buy milk
    [ ] Clean room
    [ ] Go to gym
    STRING
    
    assert_equal(string, @list.to_s)
  end
  
  def test_to_s_done
    @list.mark_done_at(1)
    
    string = <<-STRING.chomp.gsub(/^\s+/, '') # <<~STRING.chomp will work too
    --- Today's Todos ---
    [ ] Buy milk
    [X] Clean room
    [ ] Go to gym
    STRING
    
    assert_equal(string, @list.to_s)
  end
  
  def test_to_s_all_done
    @list.done!
    
    string = <<-STRING.chomp.gsub(/^\s+/, '') # <<~STRING.chomp will work too
    --- Today's Todos ---
    [X] Buy milk
    [X] Clean room
    [X] Go to gym
    STRING
    
    assert_equal(string, @list.to_s)
  end
  
  def test_each
    result = []
    @list.each { |todo| result << todo }
    assert_equal(@todos, result)
  end
  
  def test_each_return_calling_obj
    result = @list.each {}
    assert_equal(@list, result)
  end
  
  def test_select
    @list.mark_done_at(1)
    result = @list.select(&:done?)
    
    refute_same(@list, result)
    assert_equal([@todo2], result.to_a)
  end
  
  def test_reject
    @list.mark_done_at(1)
    result = @list.reject(&:done?)
    
    refute_same(@list, result)
    assert_equal([@todo1, @todo3], result.to_a)
  end
  
  def test_find_by_title
    todo = @list.find_by_title('Buy milk')
    assert_equal(@todo1, todo)
  end
  
  def test_all_done
    @list.mark_done_at(1)
    @list.mark_done_at(2)
    result = @list.all_done
    
    refute_same(@list, result)
    assert_equal([@todo2, @todo3], result.to_a)
  end
  
  def test_all_not_done
    @list.mark_done_at(1)
    result = @list.all_not_done
    
    refute_same(@list, result)
    assert_equal([@todo1, @todo3], result.to_a)
  end
  
  def test_mark_done_by_title
    assert_nil(@list.mark_done('Buy grapes'))
    
    @list.mark_done('Go to gym')
    assert_equal(true, @todo3.done?)
  end
  
  def test_mark_all_done
    @list.mark_all_done
    result = @list.select(&:done?)
    
    assert_equal(@todos, result.to_a)
  end
  
  def test_mark_all_undone
    @list.mark_all_undone
    result = @list.reject(&:done?)
    
    assert_equal(@todos, result.to_a)
  end
end
