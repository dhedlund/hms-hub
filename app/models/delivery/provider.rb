class Delivery::Provider
  def self.new(instance_name, config={})
    instance_name = instance_name.to_s
    class_name = config[:class] || "#{self.name}::#{instance_name.classify}"
    provider = class_name.constantize.new(config)

    # define a provider.name that returns the instance name
    (class << provider; self end).send(:define_method, :name) { instance_name }

    provider
  end

end
