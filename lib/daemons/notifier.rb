#!/usr/bin/env ruby

# Load EngineYard config
if File.exist?("/data/ublip/shared/config/mongrel_cluster.yml")
  mongrel_cluster = "/data/ublip/shared/config/mongrel_cluster.yml"
else
  mongrel_cluster = "/opt/ublip/rails/shared/config/mongrel_cluster.yml"
  Dir.chdir("/opt/ublip/rails/current") # For Rails 2.3.2 compat
end

# Load the env from mongrel_cluster
settings = YAML::load_file(mongrel_cluster)
ENV['RAILS_ENV'] = settings['environment']

require File.dirname(__FILE__) + "/../../config/environment"

$running,$sleeping = true,false
Signal.trap("TERM") do 
  exit if $sleeping
  $running = false
end

logger = Logger.new(File.join(RAILS_ROOT,'log','notifier.rb.log'), 'weekly')

begin
  while($running) do

    logger.info("This notification daemon is still running at #{Time.now}.\n")

    NotificationState.instance.begin_reading_bounds

    Notifier.send_geofence_notifications(logger)
    Notifier.send_device_offline_notifications(logger)
    Notifier.send_gpio_notifications(logger)
    Notifier.send_speed_notifications(logger)

    NotificationState.instance.end_reading_bounds

    Notifier.send_maintenance_notifications(logger)

    $sleeping = true
    sleep 60 if $running
    $sleeping = false

  end
rescue
  logger.info("ERROR: #{$!}")
  $!.backtrace.each {|line| logger.info line}
end