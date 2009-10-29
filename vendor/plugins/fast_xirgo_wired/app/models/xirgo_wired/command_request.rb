require 'xirgo_wired/device'

class XirgoWired::CommandRequest < ActiveRecord::Base
  establish_connection "gateway_xirgo-wired_#{RAILS_ENV}"
  set_table_name "outbound"
  
  belongs_to :device
end
