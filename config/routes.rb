ActionController::Routing::Routes.draw do |map|
  # Add your own custom routes here.
  # The priority is based upon order of creation: first created -> highest priority.
  
  # Here's a sample route:
  # map.connect 'products/:id', :controller => 'catalog', :action => 'view'
  # Keep in mind you can assign values other than :controller and :action

  # You can have the root of your site routed by hooking up '' 
  # -- just remember to delete public/index.html.
  # map.connect '', :controller => 'home'
  map.connect 'task/inbox', :controller => 'task', :action => 'list'
  map.connect '', :controller => "task", :action => 'list'

  # Allow downloading Web Service WSDL as a file with an extension
  # instead of a file named 'wsdl'
  map.connect ':controller/service.wsdl', :action => 'wsdl'

  # Install the default route as the lowest priority.
  map.connect 'search/tags/:tag', :controller => 'search',
                             :action => 'tags'
  map.connect 'tags/:tag', :controller => 'tag',
                          :action => 'show'
  map.connect 'tag/show/:tag', :controller => 'tag',
                          :action => 'show'
  map.connect 'tags/', :controller => 'search'
  map.connect ':controller/:action/:id.:format'
  map.connect ':controller/:action/:id'
  
  map.resources %w{projects tasks users}
end
