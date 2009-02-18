require 'application'

class WebservicesExtension < Radiant::Extension
  version "0.1"
  description "Adds webservices radiant tags that allows to make remote queries " +
              "to your webservices and paste results on the pages"
  
  define_routes do |map|
  end
  
  def activate
    #admin.tabs.add "Webservices", "/admin/webservices", :after => "Layouts" 
  end
  
  def deactivate
  end
  
end