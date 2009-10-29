namespace :numerex do

  desc "Perform reverse-geocoding on recent readings"
  task(:reverse_geocode_readings => :environment) do
    
    log = Logger.new(File.join(RAILS_ROOT,'log','reverse_geocode_readings.log'), 'weekly')
    
    log.info "Initializing #{$0} #{ARGV.join(' ')}"
    
    running_instances = `ps aux`.split(/\n/).select{|x| x=~ /#{$0} #{ARGV.join(' ')}/}

    if running_instances.size > 1
      running_instances.each do |instance|
        columns = instance.split(/\s+/)
        log.info "pid #{columns[1]} running since #{columns[8]}"
      end
      log.fatal "Instance already running, so I quit."
      return false
    elsif running_instances.size == 1
      log.info "I am the only instance running.  Continuing..."
    else
      log.warn "Unexpected result when trying to find instances of this program in memory"
      return false
    end
    
    log.info "START: #{Time.now}"
    ReverseGeocoder.update_recent_readings(log)
    log.info "STOP: #{Time.now}"
    log.info ""
  end
end
