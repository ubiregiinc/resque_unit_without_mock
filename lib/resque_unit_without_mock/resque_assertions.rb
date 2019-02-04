require "minitest"

module ResqueUnitWithoutMock::ResqueAssertions
  def assert_queued(klass, args = nil, &block)
    queue_name = Resque.queue_for(klass)
    queue = Resque.queued(queue_name).map{|x| JSON.parse(x) }
    assert(
      in_queue?(queue, klass, args),
      "#{klass}#{args ? " with #{args.inspect}" : ""} should have been queued in #{queue_name}: #{queue.inspect}.",
    )
  end

  def assert_not_queued(klass, args = nil, &block)
    queue_name = Resque.queue_for(klass)
    queue = Resque.queued(queue_name).map{|x| JSON.parse(x) }
    assert(
      !in_queue?(queue, klass, args),
      "#{klass}#{args ? " with #{args.inspect}" : ""} should not have been queued in #{queue_name}.",
    )
  end

  private

  def in_queue?(queue, klass, args = nil)
    !matching_jobs(queue, klass, args).empty?
  end

  def matching_jobs(queue, klass, args = nil)
    normalized_args = Resque.decode(Resque.encode(args)) if args
    queue.select {|e| e["class"] == klass.to_s && (!args || e["args"] == normalized_args )}
  end
end

Minitest::Test.include(ResqueUnitWithoutMock::ResqueAssertions)
