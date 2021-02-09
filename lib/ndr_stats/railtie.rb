module NdrStats
  # Behaviour that runs when this gem is used in the context of a Rail app.
  class Railtie < Rails::Railtie
    class << self
      def config_values
        config_from_file.merge(config_from_env)
      end

      private

      def config_from_file
        config_file = Rails.root.join('config/stats.yml')
        return {} unless File.exist?(config_file)

        YAML.load_file(config_file).symbolize_keys
      end

      def config_from_env
        config = {}

        ENV.each do |key, value|
          next unless key =~ /\ANDR_STATS_(.*)/

          config[Regexp.last_match(1).downcase.to_sym] = value
        end

        config
      end
    end

    # Auto-configures NdrStats with config in the host app, if found.
    config.after_initialize do
      config = Railtie.config_values.slice(:host, :port, :system, :stack)
      next if config.empty?

      # Try and derive system/stack from applications that expose it:
      app_class = Rails.application.class
      host_module = app_class.try(:module_parent) || app_class.parent
      config[:system] ||= host_module.try(:flavour) || host_module.name.downcase
      config[:stack] ||= host_module.try(:stack) || Rails.env

      NdrStats.configure(**config)
    end
  end
end
