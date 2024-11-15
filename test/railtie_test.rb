require 'test_helper'
require 'open3'

class RailtieTest < Minitest::Test
  def test_should_be_ok_without_configuration
    assert_runner_output 'false', 'puts NdrStats.configured?.inspect'
  end

  def test_should_work_with_basic_configuration
    with_config(basic_config) do
      assert_runner_output 'true', 'puts NdrStats.configured?.inspect'
      assert_runner_output '["stack:development", "system:dummy"]', 'puts NdrStats.adaptor.tags.sort.inspect'
    end
  end

  def test_should_work_with_basic_configuration_and_flavoured_host
    with_config(basic_config) do
      with_initializer(flavour: 'widgets', stack: 'beta') do
        assert_runner_output 'true', 'puts NdrStats.configured?.inspect'
        assert_runner_output '["stack:beta", "system:widgets"]', 'puts NdrStats.adaptor.tags.sort.inspect'
      end
    end
  end

  def test_should_work_with_full_configuration
    with_config(full_config) do
      assert_runner_output 'true', 'puts NdrStats.configured?.inspect'
      assert_runner_output '["stack:staging", "system:acme"]', 'puts NdrStats.adaptor.tags.sort.inspect'
    end
  end

  def test_should_work_with_environment_variables
    with_env('NDR_STATS_HOST' => 'localhost', 'NDR_STATS_PORT' => '9125') do
      assert_runner_output 'true', 'puts NdrStats.configured?.inspect'
      assert_runner_output '["stack:development", "system:dummy"]', 'puts NdrStats.adaptor.tags.sort.inspect'
    end
  end

  def test_should_work_with_environment_overrides
    with_config(full_config) do
      with_env('NDR_STATS_SYSTEM' => 'override') do
        assert_runner_output 'true', 'puts NdrStats.configured?.inspect'
        assert_runner_output '["stack:staging", "system:override"]', 'puts NdrStats.adaptor.tags.sort.inspect'
      end
    end
  end

  private

  def assert_runner_output(expected_output, command)
    output, _status = Open3.capture2e('bundle', 'exec', 'rails', 'runner', command, '-e', 'development', chdir: 'test/dummy')
    # Ignore Rails 7.0 deprecation warnings
    ignore = /activesupport-7.0.*no longer be part of the default gems.*|add .* to your Gemfile/
    output = output.split("\n").grep_v(ignore).join("\n")

    assert_equal expected_output, output.strip
  end

  def with_config(config, &block)
    with_file('test/dummy/config/stats.yml', config, &block)
  end

  def with_file(path, contents)
    File.open(path, 'wb') { |f| f.write contents }
    yield
  ensure
    FileUtils.rm(path)
  end

  def with_env(env)
    old_vals = {}

    env.each do |key, value|
      old_vals[key] = ENV[key]
      ENV[key] = value
    end

    yield
  ensure
    old_vals.each do |key, value|
      ENV[key] = value
    end
  end

  def with_initializer(flavour:, stack:, &block)
    with_file('test/dummy/config/initializers/my_init.rb', <<~RUBY, &block)
      class << Dummy
        def flavour; "#{flavour}"; end
        def stack; "#{stack}"; end
      end
    RUBY
  end

  def basic_config
    <<~YAML
      ---
      host: localhost
      port: 9125
    YAML
  end

  def full_config
    <<~YAML
      ---
      host: localhost
      port: 9125
      system: acme
      stack: staging
    YAML
  end
end
