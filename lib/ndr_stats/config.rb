# A fork of the original ruby client, that supports tagging:
require 'datadog/statsd'

module NdrStats
  # Contains configuration/setup logic
  module Config
    def configure(host:, port:, system: nil, stack: nil)
      tags = { system: system, stack: stack }.reject { |_key, value| value.nil? }
      NdrStats.adaptor = Datadog::Statsd.new(host, port, tags: tags)
    end

    def configured?
      !NdrStats.adaptor.nil?
    end
  end
end
