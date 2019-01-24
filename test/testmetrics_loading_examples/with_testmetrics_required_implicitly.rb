require 'bundler/inline'

gemfile do
  gem 'minitest'
  gem 'testmetrics_minitest', path: File.expand_path("../../..", __FILE__)
end

require 'minitest/autorun'

class WithTestmetricsRequiredImplicitlyTest < Minitest::Test
  def test_one
    assert true
  end
end
