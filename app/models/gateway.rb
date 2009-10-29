class Gateway
  attr_accessor :name,:label,:device_uri,:device_class
  
  @@gateway_lookup = {}
  @@gateway_list = []

  # Drop-in replacement for the old way we were doing this with gateway config files
  # We ultimately want to eliminate this model and have plugins dynamically register
  Dir.foreach("#{RAILS_ROOT}/vendor/plugins") do |dir|
    if dir == "fast_enfora" || dir == "fast_xirgo"
      gateway = Gateway.new
      gateway.name = dir.split("_")[1]
      gateway.label = gateway.name.capitalize + " Gateway"
      gateway.device_uri = "/" + gateway.name + "/command_request/list"
      gateway.device_class = gateway.name.capitalize + "::Device"
      @@gateway_list.push gateway
      @@gateway_lookup[gateway.name] = gateway
    end
  end
  
  def self.find(name)
    @@gateway_lookup[name]
  end
  
  def self.all
    @@gateway_list
  end
end
