module WebserviceTags
  include Radiant::Taggable

  tag 'webservice' do |tag|
    webservice = Webservice.find_by_title(tag.attr.delete('title'))
    if webservice
      webservice.load!(tag.attr)
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