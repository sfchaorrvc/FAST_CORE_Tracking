require 'enfora/device'

class Enfora::CommandRequest < ActiveRecord::Base
  establish_connection "gateway_enfora_#{RAILS_ENV}"
  set_table_name "outbound"
  
  belongs_to :device
end
