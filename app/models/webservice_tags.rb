module WebserviceTags
  include Radiant::Taggable

  tag 'webservice' do |tag|
    webservice = Webservice.find_by_title(tag.attr['title'])
    if webservice
      params = tag.locals.page.route_handler_params
      webservice.load!(params)
      webservice.get_data!
      tag.locals.webservice = webservice
    end
    tag.expand
  end
  
  tag 'webservice:content' do |tag|
    webservice = tag.locals.webservice
    webservice.get_value(tag.attr['select']) if webservice
  end

end