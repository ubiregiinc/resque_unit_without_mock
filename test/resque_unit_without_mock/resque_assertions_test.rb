require "test_helper"

class ResqueHelpersTest < Minitest::TestWithRedis
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
    Resque.enqueue_at(Time.new(2011,11,11,0,0,2), PrintJob)
    assert_queued_at(Time.new(2011,11,11,0,0,3), PrintJob)
    assert_not_queued_at(Time.new(2011,11,11,0,0,1), PrintJob)
  end
end
