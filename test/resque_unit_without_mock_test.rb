require "test_helper"

class ResqueUnitWithoutMockTest < Minitest::Test
  def test_that_it_has_a_version_number
    refute_nil ::ResqueUnitWithoutMock::VERSION
  end
end
