module ResqueUnitWithoutMock::ResqueHelpers
  def self.included(base)
    base.extend(ClassMethods)
  end

  module ClassMethods
    def reset!
    end

    def run!(queue_name=:normal)
      jobs = []
      loop do
        job = Resque.reserve(queue_name)
        job ? (jobs << job) : break
      end
      jobs.each(&:perform)
    end

    def queued(queue_name=:normal)
      Resque.redis.lrange("queue:#{queue_name}", 0, -1)
    end

    def queue_for(klass)
      klass.instance_variable_get(:@queue) || (klass.respond_to?(:queue) && klass.queue)
    end
  end
end
