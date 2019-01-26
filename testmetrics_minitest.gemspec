lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

Gem::Specification.new do |spec|
  spec.name          = 'testmetrics_minitest'
  spec.version       = '1.0.3'
  spec.authors       = ['Devon Estes']
  spec.email         = ['devon.c.estes@gmail.com']

  spec.summary       = 'The official Minitest client for Testmetrics'
  spec.homepage      = 'https://testmetrics.app'

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added
  # into git.
  spec.files         = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject do |f|
      f.match(%r{^(test|spec|features)/})
    end
  end
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler', '~> 1.16'
  spec.add_development_dependency 'minitest', '~> 5.0'
  spec.add_development_dependency 'rake', '~> 12.0'
  spec.add_runtime_dependency 'faraday', '>= 0.9.0'
end
