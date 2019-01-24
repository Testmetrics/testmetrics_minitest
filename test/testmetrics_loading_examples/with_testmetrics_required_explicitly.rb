require 'bundler/inline'

gemfile do
  gem 'minitest'
  gem 'testmetrics_minitest', path: File.expand_path("../../..", __FILE__), require: false
end

require 'minitest/autorun'
require 'minitest/testmetrics'

class WithTestmetricsRequiredExplicitlyTest < Minitest::Test
  def test_one
    assert true
  end
end
