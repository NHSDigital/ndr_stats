lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'ndr_stats/version'

Gem::Specification.new do |spec|
  spec.name        = 'ndr_stats'
  spec.version     = NdrStats::VERSION
  spec.authors     = ['NCRS Development team']
  spec.email       = []
  spec.summary     = 'Easy stats reporting from Ruby'
  spec.description = 'Makes it straightforward for a project to send data to statsd.'

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end

  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_dependency 'dogstatsd-ruby', '~> 4.5'

  spec.add_development_dependency 'bundler', '~> 2.0'
  spec.add_development_dependency 'minitest', '~> 5.0'
  spec.add_development_dependency 'mocha'
  spec.add_development_dependency 'ndr_dev_support'
  spec.add_development_dependency 'rails'
  spec.add_development_dependency 'rake', '~> 13.0'
end
