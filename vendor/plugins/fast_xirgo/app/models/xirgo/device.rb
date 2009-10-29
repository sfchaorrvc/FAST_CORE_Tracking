class Xirgo::Device < ActiveRecord::Base
  establish_connection "gateway_xirgo_#{RAILS_ENV}"
  attr_accessor :friendly_name
  attr_accessor :logical_device
  has_one :device, :class_name => '::Device', :foreign_key => 'imei', :primary_key => 'imei'
  
  named_scope :for_account, lambda { |account_id|
    { :joins => "join #{::Device.qualified_table_name} ublip_devices using(imei)",
      :conditions => ["ublip_devices.account_id = ?", account_id] }
  }
  
  named_scope :for_device_profile, lambda { |profile_id|
    { :joins => "join #{::Device.qualified_table_name} ublip_devices using(imei)",
      :conditions => ["ublip_devices.profile_id = ?", profile_id] }
  }

  def self.per_page
    50
  end

  def self.search_for_devices(params, page)
    scope = scoped({:order => :imei})

    unless params.nil?
      search_params = params.dup

      account_id = search_params.delete(:account_id_equals)
      scope = scope.for_account(account_id) unless account_id.blank?

      profile_id = search_params.delete(:profile_id_equals)
      scope = scope.for_device_profile(profile_id) unless profile_id.blank?

      scope.search(search_params)
    end
    
    scope.paginate(:page => page)
  end
end