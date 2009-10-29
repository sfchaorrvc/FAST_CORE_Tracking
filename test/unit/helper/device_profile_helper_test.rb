require 'test_helper'

class DeviceProfileHelperTest < ActionView::TestCase
  context "Select list for device profiles" do
    setup do
      stub(DeviceProfile).all {[]}
    end

    should "have correct id for javascript" do
      assert_match 'select id="search_profile_id_equals"', select_device_profile({})
    end

    should "have an All option" do
      assert_match '<option value="">All</option>', select_device_profile({})
    end

    should "include all device profiles" do
      mock(DeviceProfile).all{[Factory.build(:device_profile, :id => 1, :name => 'Profile')]}
      assert_match '<option value="1">Profile</option>', select_device_profile({})
    end

    should "select selected device profile" do
      mock(DeviceProfile).all{[Factory.build(:device_profile, :id => 1, :name => 'Profile')]}
      assert_match '<option value="1" selected="selected">Profile</option>',
        select_device_profile({:profile_id_equals => 1})
    end
    
    should "have label" do
      assert_match '<label for="search_profile_id_equals">', select_device_profile({})
    end
  end
end