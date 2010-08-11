ActionController::Routing::Routes.draw do |map|
  map.logout '/logout', :controller => 'sessions', :action => 'destroy'
  map.login '/login', :controller => 'sessions', :action => 'new'
  map.register '/register', :controller => 'users', :action => 'create'
  map.signup '/signup', :controller => 'users', :action => 'new'
  map.resources :users
  map.resource :session
	
  map.calls "/calls", :controller => "cdr_entries", :action => "index"
  map.calls "/calls/:extension", :controller => "cdr_entries", :action => "index"
  map.extension_detail "/calls/:extension/detail", :controller => "cdr_entries", :action => "show"
  
  map.report "/reports/:chart_type", :controller => "report", :action => "index"
  map.extension_report "/reports/:extension", :controller => "report", :action => "show"

  map.home '/', :controller => "home", :action => "index"
end
