if !system("which redis-server")
  puts '', "** can't find `redis-server` in your path"
  puts "** try running `sudo rake install`"
  abort ''
end

require 'timeout'

class RedisManeger
  ROOT = File.expand_path("../../..", __FILE__)
  REDIS_PID = "#{ROOT}/tmp/pids/redis-test.pid".freeze
  REDIS_CACHE_PATH = "#{ROOT}/tmp/cache/".freeze
  PORT = 9_736

  def self.start_redis_server
    FileUtils.mkdir_p(["#{ROOT}/tmp/pids", "#{ROOT}/tmp/cache"])
    begin
      Process.kill(:QUIT, `cat #{REDIS_PID}`.to_i)
    rescue
    end
    FileUtils.rm_rf(REDIS_PID)
    FileUtils.rm_rf("#{ROOT}/tmp/stdout")

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
    `echo "#{redis_options}"`
    puts `echo "#{redis_options}" | redis-server -`
    Timeout.timeout(2) do
      loop do
        if /PONG/ =~ `redis-cli -p #{PORT} ping`
          break
        end
      end
    end
  end

  def self.shutdown_redis_server
    begin
      `cat #{REDIS_PID} | xargs kill -QUIT`
    rescue
    end
    `rm -rf #{REDIS_CACHE_PATH}dump.rdb`
  end
end
