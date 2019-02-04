module ResqueUnitWithoutMock::Scheduler
  def self.included(base)
    base.extend(ClassMethods)
  end

  module ClassMethods
    # resque_unit前提で書かれた既存テストではResque.enqueue_atするとすぐにエンキューしながら、
    # タイムスタンプを確認している.
    # 実物Redisを使うにあたって同じ振る舞いにしたいのでクラス変数を使ってresque_unitと同じことを実現する.
    def enqueue_at(timestamp, klass, *args)
      queue = queue_for(klass)
      @@enqueue_ats ||= {}
      @@enqueue_ats[queue] ||= []
      @@enqueue_ats[queue] << { timestamp: timestamp, klass: klass, args: args }
      Resque.enqueue(klass, *args)
    end

    def enqueue_ats(queue)
      @@enqueue_ats ||= {}
      @@enqueue_ats[queue] || []
    end

    def reset!
      @@enqueue_ats = {}
    end
  end
end

Resque.include(ResqueUnitWithoutMock::Scheduler)
