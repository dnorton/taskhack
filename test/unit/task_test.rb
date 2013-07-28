require File.dirname(__FILE__) + '/../test_helper'

class TaskTest < Test::Unit::TestCase
  fixtures :tasks

  # Replace this with your real tests.
  def test_truth
    assert_kind_of Task, tasks(:first)
  end
end
