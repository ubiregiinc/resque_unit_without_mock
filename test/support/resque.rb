Resque.redis = Redis.new(host: 'localhost', port: RedisManeger::PORT)

module ResqueHelpersExt
  def reset!
    Resque.data_store.redis.flushdb
    super
  end
end
Resque.singleton_class.prepend(ResqueHelpersExt)
