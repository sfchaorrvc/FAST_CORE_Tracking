require 'test_helper'

class Xirgo::DeviceControllerTest < ActionController::TestCase
  fixtures :users
  should "call search_for_devices with params" do
    mock(Xirgo::Device).search_for_devices({"param" => :to_search}, '1') {WillPaginate::Collection.new(1,1,1)}
    get_with_user :list, {:search => {:param => :to_search}, :page => 1}, :testuser
  end
end
