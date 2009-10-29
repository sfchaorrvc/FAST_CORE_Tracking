class Xirgo::DeviceController < Xirgo::CommonController
  unloadable # making unloadable per http://dev.rubyonrails.org/ticket/6001
  def list
    @selections = {}
    @devices = Xirgo::Device.search_for_devices(params[:search], params[:page])

    return if request.get?
    if params[:device_ids]
      for device_id in params[:device_ids]
        selected_device = Xirgo::Device.find(device_id)
        raise "Xirgo::Device not found: #{device_id}" unless selected_device
        @selections[selected_device.id] = selected_device
      end
    end
    raise "No command specified" unless params[:XT3001] and !params[:XT3001].blank?
    raise "No devices selected" if @selections.empty?
    
    # Now needs to support both new and old versions of Xirgo firmware
    # The new version has ignition on/off alerts , battery threshold, and heartbeat threshold
    commands = {}
    commands["+XT:3001"] = params[:XT3001] # Ignition on
    commands["+XT:3002"] = params[:XT3002] # Ignition off
    commands["+XT:3003"] = params[:XT3003] # Degree direction change
    commands["+XT:3004"] = params[:XT3004] # Speed
    commands["+XT:3005"] = params[:XT3005] # RPM
    commands["+XT:3006"] = params[:XT3006] # Mileage
    commands["+XT:3007"] = params[:XT3007] + "," + params[:XT3007] # Accel/decel
    commands["+XT:3008"] = params[:XT3008] # Battery - new firmware only
    commands["+XT:3010"] = params[:XT3010] # Heartbeat - new firmware only
    
    # Append the first time fix event for heartbeat, if checked
    if params[:first_time_fix] == "yes"
      commands["+XT:3010"] += ",1"
    end
    
    Xirgo::CommandRequest.transaction do
      start_date_time = Time.now
      @selections.each_value do |device|
        commands.each do |command, value|
          if value != ""
            command_request = Xirgo::CommandRequest.new
            command_request.device_id = device.id
            command_request.imei = device.imei
            command_request.command = command + "," + value
            command_request.start_date_time = start_date_time
            # Ugly logic to prevent new commands from going to old firmware
            if device.imei.length > 17 && (command != "+XT:3008" && command != "+XT:3010") # Old firmware
              command_request.save!
            elsif device.imei.length < 18 # New firmware
              # Force ignition on/off events for new firmware
              if command == "+XT:3001" || command == "+XT:3002"
                command_request.command += ",1"
              end
              command_request.save!
            end
          end
        end
      end
    end
    redirect_to :controller => 'command_request',:action => 'list'
  rescue
    test = $!.to_s
    @error = $!.to_s
  end
end
