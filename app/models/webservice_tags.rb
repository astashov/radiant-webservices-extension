module WebserviceTags
  include Radiant::Taggable

  tag 'webservice' do |tag|
    webservice = Webservice.find_by_title(tag.attr.delete('title'))
    attrs = {}
    if Object.const_defined?("RouteHandlerExtension") && tag.locals.page.route_handler_params
      attrs.merge!(tag.locals.page.route_handler_params)
    end
    attrs.merge!(tag.attr)
    if webservice
      webservice.load!(attrs)
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