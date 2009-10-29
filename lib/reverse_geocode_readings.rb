#!/opt/csw/bin/ruby

# NOTE: intented for development purposes to run as a script... use "rake numerex:reverse_geocode_readings" if possible


  require File.dirname(__FILE__) + '/../config/environment'
#  ActiveRecord::Base.logger = Logger.new(STDOUT)

  STDOUT.sync = true
  log = Logger.new STDOUT

begin
  log.info "START: #{Time.now}"
  ReverseGeocoder.update_recent_readings(log)
  log.info "STOP: #{Time.now}"
rescue
  log.info "ERROR: #{$!}"
  $!.backtrace.each {|line| log.info line}
end
