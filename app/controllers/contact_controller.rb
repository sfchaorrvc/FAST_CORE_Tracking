class ContactController < ApplicationController

def index
end

def thanks
  Notifier.deliver_app_feedback(session[:email], request.subdomains.first, params[:feedback])
end

end
