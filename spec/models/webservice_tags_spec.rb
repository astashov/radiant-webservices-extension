require File.dirname(__FILE__) + '/../spec_helper'

describe WebserviceTags do
  
  before do
    @page = Page.create!(
      :title => 'New Page',
      :slug => 'page',
      :breadcrumb => 'New Page',
      :status_id => '100'
    )
    success_remote_expectations
  end
  
  it "should get remote data from webservice by <r:webservice />" do
    Webservice.create!(:title => "Geocoder", :base_url => 'http://maps.google.com/maps/geo',
      :rule_scheme => "q: boguchany\noutput: xml\nkey: abcdefg"
    )
    @page.should render("<r:webservice title='Geocoder'>Geo</r:webservice>").as('Geo')
  end
  
  it "should show remote data from webservice by <r:value-of />" do
    Webservice.create!(:title => "Geocoder", :base_url => 'http://maps.google.com/maps/geo',
      :rule_scheme => "q: boguchany\noutput: xml\nkey: abcdefg"
    )
    @page.should render(
      "<r:webservice title='Geocoder'><r:webservice:content select='.//xmlns:coordinates' /></r:webservice>"
    ).as('97.4598388,58.3798219,0')
  end
  
  it "should show nothing if webservice:content is not inside webservice" do
    Webservice.create!(:title => "Geocoder", :base_url => 'http://maps.google.com/maps/geo',
      :rule_scheme => "q: boguchany\noutput: xml\nkey: abcdefg"
    )
    @page.should render(
      "<r:webservice title='Geocoder'></r:webservice><r:webservice:content select='.//xmlns:coordinates' />"
    ).as('')
  end
  
  it "should get remote data with tag's attributes" do
    Webservice.create!(
      :title => "Geocoder", 
      :base_url => 'http://maps.google.com/maps/geo',
      :rule_scheme => "q: boguchany\noutput: xml\nkey: abcdefg"
    )
    @page.should render(
      "<r:webservice title='Geocoder' q='boguchany' output='xml'>" + 
        "<r:webservice:content select='.//xmlns:coordinates' />" + 
      "</r:webservice>"
    ).as('97.4598388,58.3798219,0')
  end
  
  if Object.const_defined?("RouteHandlerExtension")
    it "should get remote date with attributes from route_handler_params" do
      Webservice.create!(
        :title => "Geocoder", 
        :base_url => 'http://maps.google.com/maps/geo',
        :rule_scheme => "q: boguchany\noutput: xml\nkey: abcdefg"
      )
      @page.route_handler_params = { :q => 'boguchany', :output => 'xml', :something => 'some' }
      @page.should render(
        "<r:webservice title='Geocoder'>" + 
          "<r:webservice:content select='.//xmlns:coordinates' />" + 
        "</r:webservice>"
      ).as('97.4598388,58.3798219,0')
    end
  end
  
end