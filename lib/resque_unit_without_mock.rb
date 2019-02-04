module ResqueUnitWithoutMock
end

require 'resque'
require 'resque_unit_without_mock/version'
require 'resque_unit_without_mock/resque_helpers'
require 'resque_unit_without_mock/resque_assertions'

Resque.include(ResqueUnitWithoutMock::ResqueHelpers)

if defined?(Test::Unit::TestCase)
  Test::Unit::TestCase.include(ResqueUnitWithoutMock::ResqueAssertions)
end

if defined?(MiniTest::Unit::TestCase)
  MiniTest::Unit::TestCase.include(ResqueUnitWithoutMock::ResqueAssertions)
end

if defined?(Minitest::Test)
  Minitest::Test.include(ResqueUnitWithoutMock::ResqueAssertions)
end
