require "minitest/autorun"
require "minitest/testmetrics_plugin"

require 'tempfile'
require 'stringio'

class TestMinitest; end

class TestMinitest::MockTestSuite < Minitest::Test
  def test_raise_error
    raise 'raise an error'
  end

  def test_fail_assertion
    flunk 'fail assertion'
  end

  def test_skip_assertion
    skip 'skip assertion'
  end

  def test_pass
    pass
  end
end

class TestMinitest::SecondMockTestSuite < Minitest::Test
  def test_invalid_characters_in_message
    raise Object.new.inspect
  end

  def test_invalid_error_name
    raise Class.new(Exception)
  end

  def test_escaping_failure_message
    flunk "failed: doesn't like single or \"double\" quotes or symbols such as <"
  end
end

# setup test results
$reporter = Minitest::Testmetrics.new()
$reporter.start
Minitest.__run($reporter, {})
$reporter.report

Minitest::Runnable.reset

class TestMinitest::TestTestmetricsPlugin < Minitest::Test
  def test_collects_correct_results
    results = $reporter.testmetrics_results
    assert results[:key].is_a?(String)
    assert results[:branch].is_a?(String)
    assert results[:sha].is_a?(String)
    assert results[:metadata][:ruby_version].is_a?(String)
    assert results[:metadata][:ci_platform].is_a?(String)
    assert results[:total_run_time] > 10
    results[:tests].each do |test|
      assert test[:name].is_a?(String)
      assert test[:total_run_time] > 1
      assert %i[passed failed pending].include?(test[:state])
    end
  end
end

class TestMinitest::TestTestmetricsLoading < Minitest::Test
  def output
    @output ||= Tempfile.new("output")
  end

  def test_with_testmetrics_required_explicitly
    test_file = File.expand_path("../../testmetrics_loading_examples/with_testmetrics_required_explicitly.rb", __FILE__)
    system "ruby", test_file, "--testmetrics", out: output.path
    assert output.read.include?("Sending results to Testmetrics server...")
  end

  def test_with_testmetrics_required_implicitly
    test_file = File.expand_path("../../testmetrics_loading_examples/with_testmetrics_required_implicitly.rb", __FILE__)
    system "ruby", test_file, "--testmetrics", out: output.path
    assert output.read.include?("Sending results to Testmetrics server...")
  end

  def test_without_testmetrics_required
    test_file = File.expand_path("../../testmetrics_loading_examples/without_testmetrics_required.rb", __FILE__)
    system "ruby", test_file, "--testmetrics", out: output.path
    assert output.read.include?("Sending results to Testmetrics server...")
  end
end
