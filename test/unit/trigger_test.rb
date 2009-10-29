require 'test_helper'

class TriggerTest < ActiveSupport::TestCase

# Need to fix
# See https://rails.lighthouseapp.com/projects/8994/tickets/1925-mysqlerror-savepoint-active_record_1-does-not-exist-rollback-to-savepoint-active_record_1

  fixtures :accounts, :devices, :geofences

  def setup
    
    ActiveRecord::Base.connection.execute("DELETE FROM geofence_violations")
    
    file = File.new("geofence.sql")
    file.readline
    file.readline  #skip 1st two lines of file
    sql = file.read
    statements = sql.split(';;')
    
    statements.each  {|stmt| 
          query = stmt.strip
          ActiveRecord::Base.connection.execute(query) if query.size > 0
    }
    Reading.delete_all
  end
  
  def teardown
    ActiveRecord::Base.connection.execute("DROP TRIGGER IF EXISTS trig_readings_before_insert")
  end
  
  def test_enter
    now = Time.now
    reading = save_reading(32.833781, -96.756807, 1, now-900)
    assert_equal "enter", reading.geofence_event_type
    assert_equal 1, reading.geofence_id

    reading = save_reading(32.833782, -96.756807, 1, now-800)
    assert_equal "", reading.geofence_event_type

    reading = save_reading(33.833783, -96.756807, 1, now-700)
    assert_equal "exit", reading.geofence_event_type
    assert_equal 1, reading.geofence_id

    reading = save_reading(32.833784, -96.756807, 1, now-600)
    assert_equal "enter", reading.geofence_event_type
    assert_equal 1, reading.geofence_id

    reading = save_reading(32.940955, -96.822224, 1,now-500)
    assert_equal "enter", reading.geofence_event_type
    assert_equal 20, reading.geofence_id

    reading = save_reading(32.940956, -96.822224, 1,now-400)
    assert_equal "exit", reading.geofence_event_type
    assert_equal 1, reading.geofence_id
  end

  def test_account_level
    now = Time.now
    reading = save_reading(32.7977, -79.9603, 1, now-900)
    puts "device id: #{reading.device_id}"
    puts "event_type #{reading.event_type}"
    assert_equal "enter", reading.geofence_event_type
    assert_equal 4, reading.geofence_id

    reading = save_reading(32.7977, -69.9603, 1, now-800)
    assert_equal "exit", reading.geofence_event_type
    assert_equal 4, reading.geofence_id

    reading = save_reading(32.7977, -69.9603, 2, now-700)
    assert_equal "", reading.geofence_event_type

    reading = save_reading(32.7977, -79.9603, 1, now-600)
    assert_equal "enter", reading.geofence_event_type
    assert_equal 4, reading.geofence_id

    reading = save_reading(32.7977, -69.9603, 2, now-500)
    assert_equal "", reading.geofence_event_type

  end

  def test_out_of_order_entering
    outside_lat, outside_lng = 33.833783, -96.756807
    inside_lat, inside_lng = 32.833781, -96.756807
    now = Time.now

    reading = save_reading(outside_lat, outside_lng, 1, now-900)
    assert_equal "", reading.geofence_event_type

    reading = save_reading(inside_lat, inside_lng, 1, now-700)
    assert_equal "enter", reading.geofence_event_type
    
    reading = save_reading(outside_lat, outside_lng, 1, now-800)
    assert_equal "", reading.geofence_event_type

    reading = save_reading(inside_lat, inside_lng, 1, now-600)
    assert_equal "", reading.geofence_event_type
  end

  def test_out_of_order_exiting
    outside_lat, outside_lng = 33.833783, -96.756807
    inside_lat, inside_lng = 32.833781, -96.756807
    now = Time.now

    reading = save_reading(inside_lat, inside_lng, 1, now-900)
    assert_equal "enter", reading.geofence_event_type

    reading = save_reading(outside_lat, outside_lng, 1, now-700)
    assert_equal "exit", reading.geofence_event_type
    
    reading = save_reading(inside_lat, inside_lng, 1, now-800)
    assert_equal "", reading.geofence_event_type

    reading = save_reading(outside_lat, outside_lng, 1, now-600)
    assert_equal "", reading.geofence_event_type

  end

  def save_reading(latitude,longitude,device_id,created_at)
    reading = Reading.new
    reading.created_at = created_at
    reading.latitude = latitude
    reading.longitude = longitude
    reading.device_id = device_id
    reading.save
    reading.reload
    return reading
  end
  
end

