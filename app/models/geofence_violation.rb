class GeofenceViolation < ActiveRecord::Base
  belongs_to :device
  belongs_to :geofence
end
