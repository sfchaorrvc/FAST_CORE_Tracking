ActionController::Routing::Routes.draw do |map|
  map.connect 'xirgo_wired/device/:action', :controller => 'xirgo_wired/device'
  map.connect 'xirgo_wired/command_request/:action', :controller => 'xirgo_wired/command_request'
end