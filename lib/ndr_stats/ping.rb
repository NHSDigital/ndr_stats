module NdrStats
  # Ping instances make regular increments to a :ping counter,
  # as a means of checking that a progress is up.
  #
  # They can be started and stopped, as well as registered and removed
  # centrally. Generally, use via `NdrStats.ping` is recommended.
  class Ping
    # Maintain a list of started instances, to avoid accidentally
    # starting duplicates.
    class << self
      def list
        @list ||= []
      end

      def register(**args)
        instance = new(**args)

        if list.detect { |other| other.tags == instance.tags }
          raise ArgumentError, 'another tagged instance already exists!'
        else
          list << instance
        end

        instance.tap(&:start)
      end

      def remove_all
        list.each(&:stop)
        list.clear
      end
    end

    # trigger final pings, if possible:
    at_exit { Ping.remove_all }

    attr_reader :interval, :tags

    def initialize(every: 60, type:, **tags)
      @interval = every
      @tags = tags.merge!(type: type)

      @thread = nil
    end

    def start
      raise 'already started!' if running?

      initial_ping
      @thread = Thread.new { ping_forever }
      self
    end

    def stop
      return unless @thread

      @thread.kill
      @thread.join

      final_ping
    end

    def running?
      @thread&.alive?
    end

    private

    def ping_forever
      loop do
        running_ping
        sleep interval
      end
    end

    def initial_ping
      NdrStats.count(:ndr_stats_initial_ping, **tags)
    end

    def running_ping
      NdrStats.count(:ndr_stats_ping, **tags)
    end

    def final_ping
      NdrStats.count(:ndr_stats_final_ping, **tags)
    end
  end
end
