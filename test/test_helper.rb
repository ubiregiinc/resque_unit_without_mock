$LOAD_PATH.unshift File.expand_path("../../lib", __FILE__)
require "resque_unit_without_mock"

require "minitest/autorun"
require 'minitest/hooks/test'

class Minitest::TestWithRedis < Minitest::Test
  include Minitest::Hooks

  def before_all
    RedisManeger.start
  end

  def after_all
    RedisManeger.shutdown
  end
end


class RedisManeger
  require 'fileutils'
  root = File.expand_path("../..", __FILE__)
  REDIS_PID = "#{root}/tmp/pids/redis-test.pid".freeze
  REDIS_CACHE_PATH = "#{root}/tmp/cache/".freeze

  def self.start
    FileUtils.mkdir_p(['./tmp/pids', './tmp/cache'])

    redis_options = {
      'daemonize'     => 'yes',
      'pidfile'       => REDIS_PID,
      'port'          => 9_736,
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
    `
      cat "#{REDIS_PID}" | xargs kill -QUIT
      rm -f "#{REDIS_CACHE_PATH}dump.rdb"
    `
  end
end
