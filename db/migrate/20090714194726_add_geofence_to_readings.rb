class AddGeofenceToReadings < ActiveRecord::Migration
  def self.up
    add_column :readings, :geofence_id, :integer, :default => 0
    add_column :readings, :geofence_event_type, :string, :default => ''
    ActiveRecord::Base.connection.execute("UPDATE readings SET geofence_event_type = IF(SUBSTRING(event_type,2,1) = 'x', 'exit', 'enter'), geofence_id = SUBSTRING(event_type, POSITION('_' IN event_type) - LENGTH(event_type) ) WHERE event_type LIKE '%geofen%'")
  end

  def self.down
    remove_column :readings, :geofence_id
    remove_column :readings, :geofence_event_type
  end
end
