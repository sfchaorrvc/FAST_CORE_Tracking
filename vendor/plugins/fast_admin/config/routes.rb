ActionController::Routing::Routes.draw do |map|
  map.connect 'admin/dealers/:action', :controller => 'admin/dealers'
  map.connect 'admin/accounts/:action', :controller => 'admin/accounts'
  map.connect 'admin/users/:action', :controller => 'admin/users'
  map.connect 'admin/devices/:action', :controller => 'admin/devices'
  map.connect 'admin/device_profiles/:action', :controller => 'admin/device_profiles'
end