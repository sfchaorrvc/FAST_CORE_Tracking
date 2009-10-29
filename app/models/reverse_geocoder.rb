require 'json'

class ReverseGeocoder
  @@settings = nil
  @@last_failover = nil
  
  def self.webserver_list
    result = []
    @@last_failover = nil if @@last_failover and retry_primary_seconds and @@last_failover.advance(:seconds => retry_primary_seconds) < Time.now
    result.push(geonames_primary) if @@last_failover.nil? or geonames_failover.nil?
    result.push(geonames_failover) if geonames_failover
    result
  end
  
  def self.settings
    @@settings ||= YAML::load_file("#{RAILS_ROOT}/config/reverse_geocoder.yml")[ENV["RAILS_ENV"]]
  end
  
  def self.default_country
    settings["default_country"]
  end
  
  def self.geonames_primary
    settings["geonames_primary"]
  end
  
  def self.geonames_failover
    settings["geonames_failover"]
  end
  
  def self.geonames_username
    settings["geonames_username"]
  end
  
  def self.google_username
    settings["geonames_username"]
  end
  
  def self.retry_primary_seconds
    settings["retry_primary_seconds"]
  end
  
  def self.numerex_service
    settings["numerex_service"]
  end
  
  def self.update_recent_readings(log)
    for reading in Reading.all(:conditions => 'geocoded = 0',:order => 'created_at desc')
      begin
        if (result = find_reading_address(reading))
          log.info "HIT[#{reading.id}: #{result}"
        else
          log.info "MISS[#{reading.id}]: #{reading.short_address}"
        end
        reading.geocoded = true
        reading.save!
      rescue
        log.info "ERROR[#{reading.id}]: #{$!}"
        $!.backtrace.each {|line| log.info line}
      end
    end
  end
  
  def self.find_reading_address(reading)
    return unless reading.latitude and reading.longitude
    return "NUMEREX " + reading.short_address if find_numerex_reading_address(reading)
    return "GOOGLE " + reading.short_address if find_google_reading_address(reading)
    return "GEONAMES " + reading.short_address if find_geonames_reading_address(reading)
  end
  
  def self.find_google_reading_address(reading)
    url = "http://maps.google.com/maps/geo?q=#{reading.latitude},#{reading.longitude}&key=#{Google_Maps_Api_Key}"
    return unless (response = Net::HTTP.get_response(URI.parse(url)))
    return unless (body = JSON.parse(response.body))
    return unless (placemarks = body['Placemark'])
    
    best_accuracy = -1
    best_placemark = nil
    for placemark in placemarks
      next unless placemark['AddressDetails']
      next if placemark['AddressDetails']['Accuracy'].blank?
      next unless (accuracy = placemark['AddressDetails']['Accuracy'].to_i) > best_accuracy
      best_accuracy = accuracy
      best_placemark = placemark
    end

    return unless best_placemark
    details = best_placemark['AddressDetails']
    
    return unless (country = details['Country'])
    country_name = country['CountryName']
    
    return unless (state = country['AdministrativeArea'])
    state_name = [state['AdministrativeAreaName']]
    state_name.push country_name unless country_name == default_country
    reading.admin_name1 = state_name.join(', ')
    
    return reading.short_address unless (county = state['SubAdministrativeArea'])
    reading.place_name = county['SubAdministrativeAreaName'] if county['SubAdministrativeAreaName']
    
    return reading.short_address unless (locality = county['Locality'])
    reading.place_name = locality['LocalityName'] if locality['LocalityName']
    
    return reading.short_address unless (thoroughfare = locality['Thoroughfare'])
    reading.street = thoroughfare['ThoroughfareName'] if thoroughfare['ThoroughfareName']
    
    return reading.short_address
  end
  
  def self.find_numerex_reading_address(reading)
    return unless (request = Net::HTTP.get_response(URI.parse("#{numerex_service}/api/rest/AddressFinder.php?function=getAddress&lat=#{sprintf('%0.6f',reading.latitude)}&lon=#{sprintf('%0.6f',reading.longitude)}")))
    if request.body.index(/^Error/) == 0
      puts request.body
      return
    end
    state_name = grab_xml_argument(/<state_name>(.*)<\/state_name>/,request.body)
    state_abbr = grab_xml_argument(/<state_abbr>(.*)<\/state_abbr>/,request.body)
    county = grab_xml_argument(/<county>(.*)<\/county>/,request.body)
    city = grab_xml_argument(/<city>(.*)<\/city>/,request.body)
    house_number = grab_xml_argument(/<house_number>(.*)<\/house_number>/,request.body)
    dir_prefix = grab_xml_argument(/<dir_prefix>(.*)<\/dir_prefix>/,request.body)
    street = grab_xml_argument(/<street>(.*)<\/street>/,request.body)
    street_type = grab_xml_argument(/<street_type>(.*)<\/street_type>/,request.body)
    dir_suffix = grab_xml_argument(/<dir_suffix>(.*)<\/dir_suffix>/,request.body)

    result = false
    unless street.blank?
      street_parts = []
      street_parts.push dir_prefix unless dir_prefix.blank?
      street_parts.push street
      street_parts.push street_type unless street_type.blank?
      street_parts.push dir_suffix unless dir_suffix.blank?
      
      reading.street_number = house_number unless house_number.blank?
      reading.street = street_parts.join(' ')
      result = true
    end
    if not city.blank?
      result,reading.place_name = true,city
    elsif not county.blank?
      result,reading.place_name = true,county
    end
    state = state_abbr
    state = state_name if state.blank?
    result,reading.admin_name1 = true,state unless state.blank?
    return result
  end

  def self.find_geonames_reading_address(reading)
    if (req = find_nearby_address(reading.latitude,reading.longitude))
      street = grab_xml_argument(/<street>(.*)<\/street>/,req.body)
      street_number = grab_xml_argument(/<streetNumber>(.*)<\/streetNumber>/,req.body)
      placename = grab_xml_argument(/<placename>(.*)<\/placename>/,req.body)
      admin_name2 = grab_xml_argument(/<adminName2>(.*)<\/adminName2>/,req.body)
      admin_name1 = grab_xml_argument(/<adminName1>(.*)<\/adminName1>/,req.body)
      country = grab_xml_argument(/<countryCode>(.*)<\/countryCode>/,req.body)
      
      special_names = []
      special_names.push admin_name1 if admin_name1
      special_names.push country if country and country != default_country
      
      reading.street_number = street_number if street_number and street
      result,reading.street = true,street
      result,reading.place_name = true,placename if placename
      result,reading.place_name = true,admin_name2 if not result and admin_name2
      result,reading.admin_name1 = true,special_names.join(', ') if special_names.any?
      
      return 'GEONAMES1 ' + reading.short_address if result
    end

    if (req = find_nearby_placename(reading.latitude,reading.longitude))
      name = grab_xml_argument(/<name>(.*)<\/name>/,req.body)
      country = grab_xml_argument(/<countryName>(.*)<\/countryName>/,req.body)
      
      special_names = []
      special_names.push name if name
      special_names.push country if country and country != default_country
      
      result,reading.admin_name1 = true,special_names.join(', ') if special_names.any?
      
      return 'GEONAMES2 ' + reading.short_address if result
    end
  end
 
private
  def self.add_geonames_username(url)
    url += "&username=#{geonames_username}" if geonames_username
  end

  def self.add_google_username(url)
    url += "&username=#{google_username}" if google_username
  end

  def self.find_nearby_address(latitude,longitude)
    for server in webserver_list do
      begin
        return Net::HTTP.get_response(URI.parse(add_geonames_username("#{server}/geonames/servlet/geonames?srv=findNearbyAddress&lat=#{latitude}&lng=#{longitude}")))
      rescue
        @@last_failover = Time.now
        puts "GEONAMES-ERROR(#{server}): " + $!.to_s
      end
    end
    nil
  end
  
  def self.find_nearby_placename(latitude,longitude)
    return nil
    for server in webserver_list do
      begin
        return Net::HTTP.get_response(URI.parse(add_geonames_username("#{server}/findNearbyPlaceName?lat=#{latitude}&lng=#{longitude}")))
      rescue
        @@last_failover = Time.now
        puts "GEONAMES-ERROR(#{server}): " + $!.to_s
      end
    end
    nil
  end
  
  def self.grab_xml_argument(pattern,reading)
    match = pattern.match reading
    return match[1] unless match.nil?
    return nil
  end
end
