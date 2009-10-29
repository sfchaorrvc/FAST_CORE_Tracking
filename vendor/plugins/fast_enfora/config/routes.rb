ActionController::Routing::Routes.draw do |map|
  map.connect 'enfora/device/:action', :controller => 'enfora/device'
  map.connect 'enfora/command_request/:action', :controller => 'enfora/command_request'
end