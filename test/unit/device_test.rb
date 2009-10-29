require 'test_helper'

class DeviceTest < ActiveSupport::TestCase
  fixtures :devices, :accounts, :geofences, :notifications, :device_profiles, :readings, :stop_events, :idle_events, :runtime_events

  # Replace this with your real tests.
  def test_get_by_device_and_account
    device = Device.get_device(1,1)
    assert_not_nil device
    assert_equal "device 1", device.name
  end

  def test_get_device_by_account
    devices = Device.get_devices(1)
    assert_not_nil devices
    assert_equal 5, devices.size
  end

  def test_get_names_by_account
    devices = Device.get_names(1)
    assert_not_nil devices
    assert_equal 5, devices.size
  end

  def test_get_fence
    fence = devices(:device1).get_fence_by_num(1)
    assert_equal geofences(:fenceOne), fence
  
    fence = devices(:device1).get_fence_by_num(4)
    assert_nil fence
  
    fence = devices(:device2).get_fence_by_num(2)
    assert_nil fence
  end

  def test_online
    assert_equal true, devices(:device1).online?, "device 1 should be online"
    assert_equal false, devices(:device2).online?, "device 2 should be offline"
    assert_equal false, devices(:device3).online?, "device 3 should be offline"
    assert_equal true, devices(:device4).online?, "device 4 should be online"
  end

  def test_last_offline_notification
    last_offline_notification = devices(:device1).last_offline_notification
    assert_equal 2, last_offline_notification.id
  end

  def test_latest_status
    assert_equal [Device::REPORT_TYPE_STOP,"Stopped"],devices(:device1).latest_status
    assert_equal [Device::REPORT_TYPE_IDLE,"Idling"],devices(:device2).latest_status
    assert_equal [Device::REPORT_TYPE_ALL,"Moving"],devices(:device3).latest_status
    assert_equal nil,devices(:device4).latest_status
    assert_equal [Device::REPORT_TYPE_SPEEDING,"Speeding (31mph)"],devices(:device6).latest_status
    assert_equal [Device::REPORT_TYPE_RUNTIME,"On"],devices(:device7).latest_status
    assert_equal [Device::REPORT_TYPE_GPIO1,"HIGH STATUS"],devices(:device8).latest_status
  end 
  
  should "paginate search_for_devices" do
    mock(Device).by_profile_and_name{ mock!.with_latest_gps_reading {
      mock!.search("params") { mock!.paginate(:page => "1"){ WillPaginate::Collection.new(1,1,1)}}}}
    Device.search_for_devices("params", "1")
  end
end
