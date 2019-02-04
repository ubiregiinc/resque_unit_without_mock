require 'resque_unit_without_mock/scheduler'
require 'resque_unit_without_mock/scheduler_assertions'

if defined?(Test::Unit::TestCase)
  Test::Unit::TestCase.include(ResqueUnitWithoutMock::SchedulerAssertions)
end

if defined?(MiniTest::Unit::TestCase)
  MiniTest::Unit::TestCase.include(ResqueUnitWithoutMock::SchedulerAssertions)
end

if defined?(Minitest::Test)
  Minitest::Test.include(ResqueUnitWithoutMock::SchedulerAssertions)
end
