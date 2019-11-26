module NdrStats
  # The supported types of measurement. Currently just mirrors what
  # the statsd format supports, with the addition of tagging through
  # DataDog's extension to the serialisation format.
  module Stats
    def timing(name, value, **tags)
      return unless configured?

      adaptor.timing(name, value, tags: tags)
    end

    def time(name, **tags, &block)
      return yield unless configured?

      adaptor.time(name, tags: tags, &block)
    end

    def count(name, by = 1, **tags)
      return unless configured?

      adaptor.count(name, by, tags: tags)
    end

    def gauge(name, value, **tags)
      return unless configured?

      adaptor.gauge(name, value, tags: tags)
    end
  end
end
