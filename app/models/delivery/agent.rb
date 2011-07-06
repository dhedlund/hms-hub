class Delivery::Agent
  def self.instance
    @@agent ||= self.new
  end

  def initialize
    @providers = {}
  end

  def [](service)
    @providers[service.to_s]
  end

  def register(provider, service)
    @providers[service.to_s] = provider
    provider
  end

  def services
    @providers.keys.sort_by(&:to_s)
  end

  def providers
    @providers.values.uniq
  end

  def register_from_config(config)
    config[:delivery_providers].each do |service,provider_name|
      provider_config = config[provider_name.to_sym] || {}
      provider = Delivery::Provider.new(provider_name, provider_config)
      register(provider, service)
    end
  end

end
