require 'xirgo/device'

class Xirgo::CommandRequest < ActiveRecord::Base
  establish_connection "gateway_xirgo_#{RAILS_ENV}"
  set_table_name "outbound"
  
  belongs_to :device
end
