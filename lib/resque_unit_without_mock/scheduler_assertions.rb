module ResqueUnitWithoutMock::SchedulerAssertions
  def assert_queued_at(expected_timestamp, klass)
    assert_queued_at_with_queue(Resque.queue_for(klass), expected_timestamp, klass)
  end

  def assert_not_queued_at(expected_timestamp, klass)
    assert_not_queued_at_with_queue(Resque.queue_for(klass), expected_timestamp, klass)
  end

  def assert_queued_at_with_queue(queue, expected_timestamp, klass)
    result = Resque.enqueue_ats(queue).detect { |hash| hash[:timestamp] <= expected_timestamp && hash[:klass] == klass }
    assert(
      result,
      "#{klass} should have been queued in #{Resque.enqueue_ats(queue)} before #{expected_timestamp}"
    )
  end

  def assert_not_queued_at_with_queue(queue, expected_timestamp, klass)
    result = Resque.enqueue_ats(queue).detect { |hash| hash[:timestamp] <= expected_timestamp && hash[:klass] == klass }
    assert(
      !result,
      "#{klass} should not have been queued in #{Resque.enqueue_ats(queue)} before #{expected_timestamp}"
    )
  end
end
