require 'test_helper'

class Admin::DevicesControllerTest < ActionController::TestCase
  
  fixtures :users, :accounts, :devices, :device_profiles
  
  module RequestExtensions
    def server_name
      "helo"
    end
    def path_info
      "adsf"
    end
  end
  
  def setup
    @request.extend(RequestExtensions)
  end

  def test_index
    get :index, {}, get_user
    assert_response :success
  end
  
  def test_devices_table
    get :index, {}, get_user
    assert_select "table tr", 12
  end
  
  def test_new_device
    get :new, {}, get_user
    assert_response :success
  end
    
  def test_create_device_with_duplicate_imei
    post :create, {:id => 1, :device => {:imei => "1234", :account_id => 1}}, get_user
    assert_redirected_to :action => "new"
    assert_equal flash[:error], "Name can't be blank<br />Imei has already been taken<br />"
  end
  
  def test_update_device
    post :update, {:id => 1, :device => {:name => "my device", :imei => "1234", :provision_status_id => 1, :account_id => 1}}, get_user
    assert_redirected_to :action => "index"
    assert_equal flash[:success], "my device updated successfully"
  end
  
  def test_delete_device
    post :destroy, {:id => 1}, get_user
    assert_redirected_to :action => "index"
    assert_equal flash[:success], "device 1 deleted successfully"
  end
  
  def test_delete_device_with_account_filter
    # Prior to the deletion there should be 5 devices
    assert_equal 5, Device.get_devices(1).size
    post :destroy, {:id => 1, :account_id => 1}, get_user
    assert_redirected_to :action => "index"
    assert_equal flash[:success], "device 1 deleted successfully"
    # Verify that there are only 4 devices after the deletion
    assert_equal 4, Device.get_devices(1).size
  end
  
  # This test relies on getting the MSISDN from deploymanager, a remote service. Should internalize test later.
 # def test_get_msisdn_for_device
 #   device = devices(:device8)
 #   get :get_msisdn, {:key => device.imei}, get_user
 #   assert_response :success
 #   assert_match "1010974584", @response.body
 # end

  def get_user
    {:user => users(:testuser).id, :account_id => accounts(:app).id, :is_super_admin => users(:testuser).is_super_admin}
  end

  should "call search_for_devices with params" do
    mock(Device).search_for_devices({"param" => :to_search}, '1') {WillPaginate::Collection.new(1,1,1)}
      get_with_user :index, {:search => {:param => :to_search}, :page => 1}, :testuser
  end
end
