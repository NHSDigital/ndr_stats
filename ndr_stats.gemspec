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
  gem_files          = %w[CHANGELOG.md CODE_OF_CONDUCT.md LICENSE.txt README.md
                          lib ndr_stats.gemspec]
  spec.files         = `git ls-files -z`.split("\x0").
                       select { |f| gem_files.include?(f.split('/')[0]) }

  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_dependency 'dogstatsd-ruby', '~> 4.5'

  # We list development dependencies for all Rails versions here.
  # Rails version-specific dependencies can go in the relevant Gemfile.
  # rubocop:disable Gemspec/DevelopmentDependencies
  spec.add_development_dependency 'bundler', '~> 2.0'
  spec.add_development_dependency 'minitest', '~> 5.0'
  spec.add_development_dependency 'mocha'
  spec.add_development_dependency 'ndr_dev_support', '>= 5.10'
  spec.add_development_dependency 'rails'
  spec.add_development_dependency 'rake', '>= 12.3.3'
  # rubocop:enable Gemspec/DevelopmentDependencies

  spec.required_ruby_version = '>= 3.2.0'
end
