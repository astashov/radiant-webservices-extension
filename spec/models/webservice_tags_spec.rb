require File.dirname(__FILE__) + '/../spec_helper'

describe WebserviceTags do
  
  before do
    @page = Page.create!(
      :title => 'New Page',
      :slug => 'page',
      :breadcrumb => 'New Page',
      :status_id => '100'
    )
    @webservice = Webservice.create!(
      :title => "Geocoder", 
      :base_url => 'http://maps.google.com/maps/geo',
      :default_parameters => "q: boguchany\noutput: xml\nkey: abcdefg"
    )
  end
  
  it "should get remote data from webservice by <r:webservice />" do
    @page.should render("<r:webservice title='Geocoder'>Geo</r:webservice>").as('Geo')
  end
  
  it "should show remote data from webservice by <r:value-of />" do
    @page.should render(
      "<r:webservice title='Geocoder'><r:webservice:content select='.//xmlns:coordinates' /></r:webservice>"
    ).as('97.4598388,58.3798219,0')
  end
  
  it "should show nothing if webservice:content is not inside webservice" do
    @page.should render(
      "<r:webservice title='Geocoder'></r:webservice><r:webservice:content select='.//xmlns:coordinates' />"
    ).as('')
  end
  
end