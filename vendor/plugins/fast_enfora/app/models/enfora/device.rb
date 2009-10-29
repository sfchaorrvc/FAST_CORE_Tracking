class Enfora::Device < ActiveRecord::Base
  establish_connection "gateway_enfora_#{RAILS_ENV}"
  attr_accessor :friendly_name
  attr_accessor :logical_device
end
