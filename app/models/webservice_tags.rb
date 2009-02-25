module WebserviceTags
  include Radiant::Taggable

  # Tag <r:webservice>. It has only one special attribute - title. All other
  # attributes will be used as input parameters before parameters conversion
  # by Rule Scheme. Example:
  # 
  #   <r:webservice title="Geo" name="London"> ...Content here... </r:webservice>
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


  # Tag <r:webservice:content>. Used for extracting data from webservice response. 
  # It has only one parameter - select, that contains XPath for getting value from response.
  # Example:
  # 
  #   <r:webservice title="Geo" name="London">
  #     <r:webservice:content select=".//coordinates" />
  #   </r:webservice>
  tag 'webservice:content' do |tag|
    webservice = tag.locals.webservice
    webservice.get_value(tag.attr['select']) if webservice
  end

end