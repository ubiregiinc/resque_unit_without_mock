$LOAD_PATH.unshift File.expand_path("../../lib", __FILE__)
require "resque_unit_without_mock"

require 'fileutils'
require "minitest/autorun"
require 'minitest/hooks/test'
require 'resque'
require 'support/jobs'
require 'support/redis_maneger'
require 'support/resque'

class Minitest::TestWithRedis < Minitest::Test
  include Minitest::Hooks

  def before_all
    RedisManeger.start
  end

  def after_all
    RedisManeger.shutdown
  end

  def setup
    Resque.reset!
  end
end

if Resque.redis.connection[:port] == 6379
  raise 'do not use one process redis-server!'
end
