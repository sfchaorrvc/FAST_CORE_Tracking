class AddViolationTimeToGeofenceViolations < ActiveRecord::Migration
  def self.up
    add_column :geofence_violations, :violation_time, :datetime
    execute "update geofence_violations, readings SET violation_time=(select max(created_at) from readings where geofence_event_type='enter' AND readings.device_id=geofence_violations.device_id)"
  end

  def self.down
    remove_column :geofence_violations, :violation_time
  end
end
