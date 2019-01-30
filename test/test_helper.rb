$LOAD_PATH.unshift File.expand_path("../../lib", __FILE__)
require "resque_unit_without_mock"

require 'fileutils'
require "minitest/autorun"
require 'minitest/hooks/test'
require 'resque'

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

class RedisManeger
  root = File.expand_path("../..", __FILE__)
  REDIS_PID = "#{root}/tmp/pids/redis-test.pid".freeze
  REDIS_CACHE_PATH = "#{root}/tmp/cache/".freeze
  PORT = 9_736

  def self.start
    FileUtils.mkdir_p(['./tmp/pids', './tmp/cache'])
    FileUtils.rm_rf("#{REDIS_CACHE_PATH}/stdout")

    redis_options = {
      'daemonize'     => 'yes',
      'pidfile'       => REDIS_PID,
      'port'          => PORT,
      'timeout'       => 300,
      'save 900'      => 1,
      'save 300'      => 1,
      'save 60'       => 10_000,
      'dbfilename'    => 'dump.rdb',
      'dir'           => REDIS_CACHE_PATH,
      'loglevel'      => 'debug',
      'logfile'       => 'stdout',
      'databases'     => 16
    }.map { |k, v| "#{k} \"#{v}\"" }.join("\n")
    `echo '#{redis_options}' | redis-server -`
  end

  def self.shutdown
    Process.kill(:QUIT, File.read(REDIS_PID).chomp.to_i)
    FileUtils.rm_rf("#{REDIS_CACHE_PATH}dump.rdb")
  end
end

Resque.redis = Redis.new(host: 'localhost', port: RedisManeger::PORT, thread_safe: true)

class PrintJob
  @queue = :normal
  def self.perform
    puts 'hello PrintJob'
  end
end

class EndlessJob
  @queue = :normal
  def self.perform
    Resque.enqueue(self)
  end
end

module ResqueHelpersExt
  def reset!
    Resque.data_store.redis.flushdb
    super
  end
end
Resque.singleton_class.prepend(ResqueHelpersExt)
