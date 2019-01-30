require "test_helper"

class ResqueHelpersTest < Minitest::TestWithRedis
  def test_enqueue_at
    assert_equal([], Resque.queued(:normal))
    assert_equal([], Resque.enqueue_ats)
    Resque.enqueue_at(Time.new(2011,11,11,0,0,0), PrintJob, 'test_enqueue_at')
    assert_equal(1, Resque.queued(:normal).size)
    assert_equal(1, Resque.enqueue_ats.size)
  end

  def test_do_not_endless_job
    Resque.enqueue(EndlessJob)
    assert_equal(1, Resque.queued(:normal).size)
    Resque.run!
    assert_equal(1, Resque.queued(:normal).size)
  end

  def test_enqueue_job
    lrange_block = ->{ Resque.redis.lrange('queue:normal', 0, -1) }
    assert(lrange_block.call.empty?)
    assert(Resque.queued(:normal).empty?)
    Resque.enqueue(PrintJob, 'test_enqueue_job')
    refute(lrange_block.call.empty?)
    refute(Resque.queued(:normal).empty?)
  end
end
