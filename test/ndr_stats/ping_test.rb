require 'test_helper'

module NdrStats
  class PingTest < Minitest::Test
    def setup
      Ping.remove_all
    end

    def test_should_be_registerable
      Ping.any_instance.expects(:start).once
      assert_kind_of Ping, Ping.register(type: 'quiet')
    end

    def test_should_be_registerable_via_ping
      Ping.any_instance.expects(:start).once
      assert_kind_of Ping, NdrStats.ping(type: 'quiet')
    end

    def test_should_not_allow_registration_of_duplicates
      Ping.any_instance.expects(:start).twice
      assert_kind_of Ping, Ping.register(type: 'quiet')
      assert_kind_of Ping, Ping.register(type: 'loud')

      exception = assert_raises(ArgumentError) { Ping.register(type: 'quiet') }
      assert_match(/tagged instance already exists/, exception.message)
    end

    def test_should_require_type_tag
      tags = { type: 'quiet', volume: 'low' }
      ping = Ping.new(**tags)
      assert_equal tags, ping.tags

      exception = assert_raises(ArgumentError) { Ping.new(volume: 'low') }
      assert_match(/missing keyword: :?type/, exception.message)
    end

    def test_interval_should_be_configurable
      assert_equal 60, Ping.new(type: 'default').interval
      assert_equal 3, Ping.new(type: 'rapid', every: 3).interval
    end

    def test_should_not_be_running_initially
      Ping.any_instance.expects(:start).never
      ping = Ping.new(type: 'test')
      refute ping.running?
    end

    def test_should_be_running_when_started
      ping = Ping.new(type: 'test').start
      assert ping.running?
      ping.stop
      refute ping.running?
    end

    def test_should_increment_ping_counters
      expected_tags = { type: 'test' }

      NdrStats.expects(:count).with do |name, tags|
        name == :ndr_stats_initial_ping && tags == expected_tags
      end.once

      NdrStats.expects(:count).with do |name, tags|
        name == :ndr_stats_ping && tags == expected_tags
      end.at_least_once

      NdrStats.expects(:count).with do |name, tags|
        name == :ndr_stats_final_ping && tags == expected_tags
      end.once

      Ping.register(type: 'test', every: 0.01)
      sleep 0.05
      Ping.remove_all
    end
  end
end
