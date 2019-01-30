# TODO don't use Concern
module ResqueUnitWithoutMock::ResqueHelpers
  @@enqueue_ats = []
  attr_reader :enqueue_ats

  def self.included(base)
    base.extend(ClassMethods)
  end

  module ClassMethods
    # resque_unit前提で書かれた既存テストではResque.enqueue_atするとすぐにエンキューしながら、
    # タイムスタンプを確認している.
    # 実物Redisを使うにあたって同じ振る舞いにしたいのでクラス変数を使ってresque_unitと同じことを実現する.
    def enqueue_at(timestamp, klass, *args)
      enqueue_ats << { timestamp: timestamp, klass: klass, args: args }
      Resque.enqueue(klass, *args)
    end

    def reset!
      @@enqueue_ats = []
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

Resque.include(ResqueUnitWithoutMock::ResqueHelpers)
