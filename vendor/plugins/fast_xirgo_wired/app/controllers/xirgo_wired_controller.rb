class XirgoWiredController < ApplicationController
  unloadable # making unloadable per http://dev.rubyonrails.org/ticket/6001
  before_filter :authorize_super_admin
  layout 'admin'
  
  def index
    begin
      @total_devices = XirgoWired::Device.count
      @total_requests = XirgoWired::CommandRequest.count
    rescue
      render :partial => "not_available"
    end
  end
  
end