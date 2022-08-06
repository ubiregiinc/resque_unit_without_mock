require "test_helper"
require "resque_unit_without_mock_scheduler"

class ResqueSchedulersTest < Minitest::TestWithRedis
  def test_enqueue_at
    assert_equal([], Resque.queued(:normal))
    assert_equal([], Resque.enqueue_ats(:normal))
    Resque.enqueue_at(Time.new(2011,11,11,0,0,0), PrintJob, 'test_enqueue_at')
    assert_equal(1, Resque.queued(:normal).size)
    assert_equal(1, Resque.enqueue_ats(:normal).size)
  end

  def test_assert_queued
    assert_not_queued(PrintJob)
    Resque.enqueue(PrintJob)
    assert_queued(PrintJob)
    Resque.reset!
    assert_not_queued(PrintJob)
  end

  def test_assert_queued_at
    #      |=> queued!!
    #  |   |\\|\\\\\\\\
    #  1   2  3
    assert_not_queued_at(Time.new(2011,11,11,0,0,2), PrintJob)
    assert_not_queued_at(Time.new(2011,11,11,0,0,3), PrintJob)
    Resque.enqueue_at(Time.new(2011,11,11,0,0,2), PrintJob)
    assert_not_queued_at(Time.new(2011,11,11,0,0,1), PrintJob)
    assert_queued_at(Time.new(2011,11,11,0,0,2), PrintJob)
    assert_queued_at(Time.new(2011,11,11,0,0,3), PrintJob)
  end

  def test_assert_queued_at_with_queue
    #      |=> queued!!
    #  |   |\\|\\\\\\\\
    #  1   2  3
    assert_not_queued_at(Time.new(2011,11,11,0,0,2), PrintJob)
    assert_not_queued_at(Time.new(2011,11,11,0,0,3), PrintJob)
    Resque.enqueue_at_with_queue(:normal, Time.new(2011,11,11,0,0,2), PrintJob)
    assert_not_queued_at(Time.new(2011,11,11,0,0,1), PrintJob)
    assert_queued_at(Time.new(2011,11,11,0,0,2), PrintJob)
    assert_queued_at(Time.new(2011,11,11,0,0,3), PrintJob)
  end
end
