# initializes delivery providers for use by the delivery agent
providers_file = Rails.root.join('config', 'delivery.yml')
config = YAML::load(ERB.new(providers_file.read).result)[Rails.env]
HmsHub::Application.config.delivery_agent = config
