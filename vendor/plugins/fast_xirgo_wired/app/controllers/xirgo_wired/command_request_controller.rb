class XirgoWired::CommandRequestController < XirgoWired::CommonController
  unloadable # making unloadable per http://dev.rubyonrails.org/ticket/6001
  def compose
    @command_request = XirgoWired::CommandRequest.new(:device_id => params[:id])
  end
  
  def submit
    @command_request = XirgoWired::CommandRequest.new(params[:command_request])
    @command_request.start_date_time = Time.now
    @command_request.save!
    redirect_to :action => "check_status",:id => @command_request
  rescue
    @error = $!.to_s
    @command_request ||= XirgoWired::CommandRequest.new
  end

  def upload
    @command_request = XirgoWired::CommandRequest.find(params[:id])
    if request.post?
      command_found = false
      @expect = 'OK'
      @script = []
      params[:file].each do | line |
        line.strip!
        entry = {:line => line}
        entry[:comment] = line[/\#.*/]
        line = line[/^[^#]*/].strip if entry[:comment]
        if line.blank?
          entry[:blank] = true
        elsif line[0,1] == '!'
          @expect = line[1,line.length - 1].upcase
          next
        else
          entry[:command] = line
          entry[:expect] = @expect
          command_found = true
        end
        @script.push(entry)
      end
      return if command_found
      @script = nil
      @error = "No commands found"
    end
  rescue
    @error = $!.to_s
    @command_request ||= XirgoWired::CommandRequest.new
  end
  
  def script
    @command_request = XirgoWired::CommandRequest.find(params[:id])
  rescue
    @error = $!.to_s
    @command_request ||= XirgoWired::CommandRequest.new
  end
  
  def list
    @device = XirgoWired::Device.find(params[:id]) if params[:id]
    @device ||= XirgoWired::Device.new
    conditions = "device_id = #{@device.id}" if @device.id
    @command_requests = XirgoWired::CommandRequest.find(:all,:conditions => conditions,:order => "start_date_time desc", :limit => 25)
  end
  
  # If the command fails allow the user to retry
  def retry
    command_request = XirgoWired::CommandRequest.find(params[:id])
    command_request.end_date_time = nil
    command_request.status = "Processing"
    command_request.save
    redirect_to "/xirgo/command_request/list"
  end
  
  def check_status
    @command_request = XirgoWired::CommandRequest.find(params[:id])
    @device = (@command_request.device or Device.new)
  rescue
    @error = $!.to_s
    @command_request ||= XirgoWired::CommandRequest.new
    @device ||= Device.new
  end
end
