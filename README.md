# Testmetrics MiniTest [![CircleCI](https://circleci.com/gh/Testmetrics/testmetrics_minitest.svg?style=svg)](https://circleci.com/gh/Testmetrics/testmetrics_minitest)

The official MiniTest client for [Testmetrics](https://www.testmetrics.app). This client collects data
about your MiniTest test suites after being run in CI and sends that data to
Testmetrics so you can gain valuable insights about your test suite.

## Usage

Add it to your Gemfile in the same groups as MiniTest.

```ruby
group :test do
  gem "minitest"
  gem "testmetrics_minitest"
end
```

Then, right after your call to `require 'minitest'`, add
`require 'minitest/testmetrics'` to enable the Testmetrics reporter.

See [here](https://github.com/devonestes/sinatra/commit/6b5229d79f01c8f5ffb3ae2263c62b70d19da024) for a diff showing
exactly what was needed to add Testmetrics to Sinatra - it's just 3 lines!

In order for the metrics to be sent to Testmetrics, you must have your
Testmetrics Project Key set in the `TESTMETRICS_PROJECT_KEY` environment
variable in your CI environment. If this environment variable isn't set, the
collected metrics for your CI run will be discarded.

## License

`testmetrics_minitest` is offered under the MIT license. For the full license
text see [LICENSE](https://github.com/testmetrics/testmetrics_minitest/blob/master/LICENSE).
