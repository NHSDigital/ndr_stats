require 'ndr_stats/version'

require 'ndr_stats/config'
require 'ndr_stats/ping'
require 'ndr_stats/railtie' if defined?(Rails)
require 'ndr_stats/stats'

# Code to allow instrumentation to be fed back to prometheus.
#
#   # Icrement a counter by one:
#   NdrStats.count('sheep', colour: 'black')
#   # Or by many:
#   NdrStats.count('rabbits', 10)
#
#   # Set a gauge:
#   NdrStats.gauge('active_daemons', 10)
#
#   # Time some code:
#   NdrStats.time('validation', class: 'Tumour') { @tumour.valid? }
#
module NdrStats
  extend Config
  extend Stats

  class << self
    attr_accessor :adaptor

    # Register some tags to update the :ping counter periodically.
    #
    #   # basic tagged ping:
    #   NdrStats.ping(type: 'webapp')

    #   # supply additional tags:
    #   NdrStats.ping(type: 'daemon', name: 'batch importer')

    #   # set a custom frequency (defaults to every minute):
    #   NdrStats.ping(type: 'sloth', every: 3.hours)
    #
    def ping(**args)
      Ping.register(**args)
    end
  end
end
