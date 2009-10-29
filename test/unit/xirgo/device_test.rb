require 'test_helper'

class Xirgo::DeviceTest < ActiveSupport::TestCase
  context "searching for devices" do
    should "paginate" do
      mock(Xirgo::Device).paginate(:page => 1)
      Xirgo::Device.search_for_devices({}, 1)
    end
  
    should "filter by account" do
      stub.proxy(Xirgo::Device).scoped do |scope|
        mock! do
          for_account("6") {scope}
        end
      end
    
      Xirgo::Device.search_for_devices({:account_id_equals => "6"}, nil)
    end
  
    should "filter by device profile" do
      stub.proxy(Xirgo::Device).scoped do |scope|
        mock! do
          for_device_profile("5") {scope}
        end
      end
    
      Xirgo::Device.search_for_devices({:profile_id_equals => "5"}, nil)
    end
  
    should "not change search params" do
      params = {:account_id_equals => "6"}
      Xirgo::Device.search_for_devices(params, nil)
      assert_equal "6", params[:account_id_equals]
    end
  end
end