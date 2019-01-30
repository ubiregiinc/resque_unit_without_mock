$LOAD_PATH.unshift File.expand_path("../../lib", __FILE__)
require "resque_unit_without_mock"

require "minitest/autorun"
require 'minitest/hooks/test'

class Minitest::TestWithRedis < Minitest::Test
  include Minitest::Hooks

  def before_all
    puts 'start redis'
    # TODO
  end

  def after_all
    puts 'shutdown redis'
    # TODO
  end
end
