class WebservicesExtension < Radiant::Extension
  version "0.1"
  description "Adds webservices radiant tags that allows to make remote queries " +
              "to your webservices and paste results on the pages"
  
  define_routes do |map|
    map.namespace :admin, :member => { :remove => :get } do |admin|
      admin.resources :webservices
    end
  end
  
  def activate
    admin.tabs.add "Webservices", "/admin/webservices", :after => "Layouts" 
    Page.send :include, WebserviceTags
  end
  
  def deactivate
  end
  
end
