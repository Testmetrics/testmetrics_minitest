require 'time'
require 'faraday'
require 'json'

module Minitest
  def self.plugin_testmetrics_options(opts, _options)
    opts.on "--testmetrics", "Enable Minitest::Testmetrics Reporting." do
      Testmetrics.report!
    end
  end

  def self.plugin_testmetrics_init(options)
    if Testmetrics.report?
      self.reporter << Testmetrics.new(options)
    end
  end

  class Testmetrics < Reporter
    class << self
      def report!
        @enabled = true
      end

      def report?
        @enabled ||= false
      end
    end

    attr_accessor :options, :testmetrics_results, :results

    def initialize(options = {})
      self.options = options
      self.results = Hash.new { |h, k| h[k] = [] }
      self.testmetrics_results = {
        key: ENV['TESTMETRICS_PROJECT_KEY'] || 'Unknown',
        branch: git_branch,
        sha: git_sha,
        metadata: {
          ruby_version: RUBY_VERSION,
          ci_platform: ci_platform
        },
        tests: []
      }
      post_results(testmetrics_results) unless testmetrics_results[:key] == 'Unknown'
    end

    def start
      nil
    end

    def record(result)
      key = result.respond_to?(:klass) ? result.klass : result.class
      results[key] << result
    end

    def report
      total_time = 0

      results.each do |name, class_results|
        class_results.each do |result|
          total_time += time_in_microseconds(result.time)
          result.name
          testmetrics_results[:tests] << {
            name: "#{name}.#{result.name.delete("\0").delete("\x01").delete("\e")}",
            total_run_time: time_in_microseconds(result.time),
            state: state(result.failure)
          }
        end
      end

      testmetrics_results[:total_run_time] = total_time
      post_results(testmetrics_results) unless testmetrics_results[:key] == 'Unknown'
    end

    private

    BRANCH_VARS = %w[
      TRAVIS_EVENT_TYPE
      CIRCLE_BRANCH
      CI_COMMIT_REF_NAME
      BRANCH_NAME
    ].freeze
    def git_branch
      correct_var = correct_var(BRANCH_VARS)

      if correct_var == 'TRAVIS_EVENT_TYPE'
        travis_branch(correct_var)
      else
        correct_var.nil? ? 'Unknown' : ENV[correct_var]
      end
    end

    def travis_branch(var)
      case ENV[var]
      when 'push'
        ENV['TRAVIS_BRANCH']
      when 'pull_request'
        ENV['TRAVIS_PULL_REQUEST_BRANCH']
      end
    end

    SHA_VARS = %w[TRAVIS_COMMIT CIRCLE_SHA1 CI_COMMIT_SHA REVISION].freeze
    def git_sha
      correct_var = correct_var(SHA_VARS)
      correct_var.nil? ? 'Unknown' : ENV[correct_var]
    end

    def ci_platform
      case correct_var(SHA_VARS)
      when 'TRAVIS_COMMIT' then 'Travis CI'
      when 'CIRCLE_SHA1' then 'Circle CI'
      when 'CI_COMMIT_SHA' then 'Gitlab CI'
      when 'REVISION' then 'Semaphore CI'
      else 'Unknown'
      end
    end

    def correct_var(vars)
      vars.find { |var| !ENV[var].nil? && ENV[var] != '' }
    end

    def post_results(results)
      puts "\nSending results to Testmetrics server..."

      Faraday.post do |req|
        req.url 'https://www.testmetrics.app/results'
        req.headers['Content-Type'] = 'application/json'
        req.body = results.to_json
      end
    end

    def time_in_microseconds(time)
      (time * 1_000_000).round(0)
    end

    def state(failure)
      case failure
      when Skip
        :pending
      when UnexpectedError
        :failed
      when Assertion
        :failed
      else
        :passed
      end
    end
  end
end
