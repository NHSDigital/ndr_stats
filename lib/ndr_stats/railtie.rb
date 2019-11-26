module NdrStats
  # Behaviour that runs when this gem is used in the context of a Rail app.
  class Railtie < Rails::Railtie
    # Auto-configures NdrStats with config in the host app, if found.
    initializer 'ndr_stats.detect_host_configuration' do
      config_file = Rails.root.join('config', 'ndr_stats.yml')
      next unless File.exist?(config_file)

      config = YAML.load_file(file).with_indifferent_access.
               slice(%i[host port system stack]).
               reject { |_, value| value.blank? }

      # Try and derive system/stack from applications that expose it:
      host_module = Rails.application.class.parent
      config[:system] ||= host_module.try(:flavour) || host_module.name.downcase
      config[:stack] ||= host_module.try(:stack) || Rails.env

      NdrStats.configure(config)
    end
  end
end
