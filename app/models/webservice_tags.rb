module WebserviceTags
  include Radiant::Taggable

  tag 'webservice' do |tag|
    webservice = Webservice.find_by_title(tag.attr.delete('title'))
    attrs = {}
    necessary_attrs = tag.attr.delete('route_handler_params')
    if Object.const_defined?("RouteHandlerExtension") && tag.locals.page.route_handler_params && necessary_attrs
      necessary_attrs = necessary_attrs.split(",").map {|p| p.strip.to_sym}
      tag.locals.page.route_handler_params.each do |key, value| 
        attrs[key] = value if necessary_attrs.include?(key)
      end
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