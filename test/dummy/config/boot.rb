# Use the specified gemfile, defaulting to ndr_stats's Gemfile.
ENV['BUNDLE_GEMFILE'] ||= File.expand_path('../../../Gemfile', __dir__)

require 'bundler'
Bundler.setup
