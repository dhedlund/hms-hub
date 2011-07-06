# initializes delivery providers for use by the delivery agent
providers_file = Rails.root.join('config', 'delivery.yml')
config = YAML::load(ERB.new(providers_file.read).result)[Rails.env]
config =  HashWithIndifferentAccess.new(config)
Delivery::Agent.instance.register_from_config(config)
