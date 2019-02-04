$LOAD_PATH.unshift File.expand_path("../../lib", __FILE__)
require "resque_unit_without_mock"

require 'fileutils'
require "minitest/autorun"
require 'minitest/hooks/test'
require 'resque'
require 'support/jobs'
require 'support/redis_maneger'
require 'support/resque'

if Resque.data_store.redis.connection[:port] == 6379
  raise 'Use one-off redis-server process!'
end

class Minitest::TestWithRedis < Minitest::Test
  include Minitest::Hooks

  def setup
    Resque.reset!
  end
end

MiniTest.after_run do
  RedisManeger.shutdown_redis_server
end

RedisManeger.start_redis_server
