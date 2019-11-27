module NdrStats
  # Behaviour that runs when this gem is used in the context of a Rail app.
  class Railtie < Rails::Railtie
    # Auto-configures NdrStats with config in the host app, if found.
    config.after_initialize do
      config_file = Rails.root.join('config', 'stats.yml')
      next unless File.exist?(config_file)

      config = YAML.load_file(config_file).symbolize_keys.
               slice(:host, :port, :system, :stack).
               reject { |_, value| value.blank? }

      # Try and derive system/stack from applications that expose it:
      app_class = Rails.application.class
      host_module = app_class.try(:module_parent) || app_class.parent
      config[:system] ||= host_module.try(:flavour) || host_module.name.downcase
      config[:stack] ||= host_module.try(:stack) || Rails.env

      NdrStats.configure(**config)
    end
  end
end
