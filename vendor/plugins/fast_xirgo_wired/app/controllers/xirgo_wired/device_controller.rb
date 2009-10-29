class XirgoWired::DeviceController < XirgoWired::CommonController
  unloadable # making unloadable per http://dev.rubyonrails.org/ticket/6001
  def list
    @selections = {}
    @devices = XirgoWired::Device.search_for_devices(params[:search], params[:page])

    return if request.get?
    if params[:device_ids]
      for device_id in params[:device_ids]
        selected_device = XirgoWired::Device.find(device_id)
        raise "XirgoWired::Device not found: #{device_id}" unless selected_device
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
    commands["+XT:3006"] = params[:XT3006] # Mileage
    commands["+XT:3008"] = params[:XT3008] # Battery - new firmware only
    commands["+XT:3009"] = params[:XT3009] # Battery disconnect alert
    commands["+XT:3010"] = params[:XT3010] # Heartbeat - new firmware only
    commands["+XT:3012"] = 1 # Hardcoding ignition type to wired
    
    # Append the first time fix event for heartbeat, if checked
    if params[:first_time_fix] == "yes"
      params[:XT3010] += ",1"
    else
      params[:XT3010] += ",0"
    end
    
    # Below is the batch command format for wired Xirgo units
    #+XT:3040,<IGNITION ON INTERVAL>,<IGNITION ON ALERT>,<IGNITION OFF INTERVAL>,<IGNITION OFF ALERT>,<DEGREE OF DIRECTION CHANGE>,<SPEED THRESHOLD ALERT>,<MILEAGE THRESHOLD ALERT>,<BATTERY THRESHOLD ALERT>,<MAIN BATTERY DISCONNECT INTERVAL>, <MAIN BATTERY DISCONNECT ALERT>,<HEARTBEAT THRESHOLD ALERT>,<FIRST TIME GPS FIX ALERT>,<BUZZER TYPE>,<IGNITION TYPE>,<AUX INPUT TYPE>
    
    batch_command = "+XT:3040,#{params[:XT3001]},1,#{params[:XT3002]},1,#{params[:XT3003]},#{params[:XT3004]},#{params[:XT3006]},#{params[:XT3008]},0,0,#{params[:XT3010]},0,1,0"
    
    XirgoWired::CommandRequest.transaction do
      start_date_time = Time.now
      @selections.each_value do |device|
        command_request = XirgoWired::CommandRequest.new
        command_request.device_id = device.id
        command_request.imei = device.imei
        command_request.command = batch_command #command + "," + value
        command_request.start_date_time = start_date_time
        command_request.save!
      end
    end
    redirect_to :controller => 'command_request',:action => 'list'
  rescue
    test = $!.to_s
    @error = $!.to_s
  end
end
