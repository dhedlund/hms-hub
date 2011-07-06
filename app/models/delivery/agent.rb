class Delivery::Agent
  def self.instance
    @@agent ||= self.new
  end

  def initialize
    @providers = {}
  end

  def [](service)
    @providers[service]
  end

  def register(provider, service)
    @providers[service] = provider
    provider
  end

  def services
    @providers.keys.sort_by(&:to_s)
  end

  def providers
    @providers.values.uniq
  end

end
