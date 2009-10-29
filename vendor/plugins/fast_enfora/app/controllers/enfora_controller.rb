class EnforaController < ApplicationController
  unloadable # making unloadable per http://dev.rubyonrails.org/ticket/6001  
  before_filter :authorize_super_admin
  layout 'admin'
  
  def index
    @total_devices = Enfora::Device.count
    @total_requests = Enfora::CommandRequest.count
  end
  
end
