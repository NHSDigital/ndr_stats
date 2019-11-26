require 'test_helper'

class NdrStatsTest < Minitest::Test
  def setup
    wipe_config
  end

  def test_that_it_has_a_version_number
    refute_nil ::NdrStats::VERSION
  end

  def test_that_it_is_not_configured_by_default
    refute NdrStats.configured?
  end

  def test_that_it_is_configurable
    with_configuration do
      assert NdrStats.configured?

      adaptor = NdrStats.adaptor
      assert_kind_of Datadog::Statsd, adaptor
      assert_equal 'test.host', adaptor.connection.host
      assert_equal 9125, adaptor.connection.port
      assert_equal %w[system:app stack:live], adaptor.tags
    end
  end

  def test_when_configured_methods_are_sent_to_adaptor
    Datadog::Statsd.any_instance.expects(:count).once
    with_configuration { NdrStats.count(:sheep) }
  end

  def test_when_not_configured_methods_do_nothing
    refute NdrStats.count(:sheep)
  end

  private

  def with_configuration
    config = { host: 'test.host', port: 9125, system: 'app', stack: 'live' }
    NdrStats.configure(**config)
    yield
  ensure
    wipe_config
  end

  def wipe_config
    NdrStats.adaptor = nil
  end
end
