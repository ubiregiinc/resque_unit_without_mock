# TODO don't use Concern
module ResqueUnitWithoutMockTest::ResqueHelpers
  extend ActiveSupport::Concern

  included do
    mattr_accessor :enqueue_ats, instance_accessor: false, default: []
  end

  class_methods do
    # resque_unit前提で書かれた既存テストではResque.enqueue_atするとすぐにエンキューしながら、
    # タイムスタンプを確認している.
    # 実物Redisを使うにあたって同じ振る舞いにしたいのでクラス変数を使ってresque_unitと同じことを実現する.
    def enqueue_at(timestamp, klass, *args)
      enqueue_ats << { timestamp: timestamp, klass: klass, args: args }
      klass.perform_async(*args)
    end

    def reset!
      self.enqueue_ats = []
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
      sample_queues = Resque.sample_queues[queue_name.to_s] || {}
      (sample_queues[:samples] || []).map(&:to_json)
    end

    def queue_for(klass)
      klass.instance_variable_get(:@queue) || (klass.respond_to?(:queue) && klass.queue)
    end
  end
end

Resque.include(ResqueUnitWithoutMockTest::ResqueHelpers)
