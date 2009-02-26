module WebserviceTags
  include Radiant::Taggable

  desc %{
    Makes remote request to webservice. It has only one special attribute - @name@. All other
    attributes will be used as input parameters before conversion of these parameters
    by Rule Scheme.

    *Usage:*

    <pre><code><r:webservice name="webservice_title" [other attributes...]>...</r:webservice></code></pre>
  }
  tag 'webservice' do |tag|
    webservice = Webservice.find_by_title(tag.attr.delete('name'))
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

  desc %{
   Shows some value from webservice response. It has only one attribute - @select@, 
   that contains XPath for getting values from response.
   
   *Usage: (withing webservice tag)*
   
   <pre><code><r:webservice name="webservice_title" [other attributes...]>
     <r:webservice:content select="//some/xpath" />
   </r:webservice></code></pre>
  }
  tag 'webservice:content' do |tag|
    webservice = tag.locals.webservice
    webservice.get_value(tag.attr['select']) if webservice
  end

end