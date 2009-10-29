ActionController::Routing::Routes.draw do |map|
  map.connect 'xirgo/device/:action', :controller => 'xirgo/device'
  map.connect 'xirgo/command_request/:action', :controller => 'xirgo/command_request'
end