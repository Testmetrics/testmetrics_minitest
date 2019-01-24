require 'bundler/inline'

gemfile do
  gem 'minitest'
  gem 'testmetrics_minitest', path: File.expand_path("../../..", __FILE__), require: false
end

require 'minitest/autorun'

class WithoutTestmetricsRequiredTest < Minitest::Test
  def test_one
    assert true
  end
end
