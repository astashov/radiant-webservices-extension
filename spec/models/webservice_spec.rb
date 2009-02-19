require File.dirname(__FILE__) + '/../spec_helper'
require 'nokogiri'
describe Webservice do
  
  it "should be created" do
    lambda do
      Webservice.create!(:title => "Metis", :base_url => 'https://metis.astrology.com/api/content_items')
    end.should change(Webservice, :count).by(1)
  end
  
  it "should be validated by presence" do
    webservice = Webservice.new
    webservice.should_not be_valid
    webservice.errors.on(:title).should_not be_nil
    webservice.errors.on(:base_url).should_not be_nil
  end
  
  it "should be validated by uniqueness" do
    Webservice.create!(:title => "Metis", :base_url => "url")
    webservice = Webservice.new(:title => "Metis")
    webservice.should_not be_valid
    webservice.errors.on(:title).should_not be_nil
  end  

  it "should correctly not transform invalid YAML" do
    webservice = Webservice.new(:title => "web", :base_url => "url", :rule_scheme => "as: as: 'sadf")
    webservice.should_not be_valid
    webservice.errors.on(:rule_scheme).should_not be_nil
  end
  
  it "should correctly not transform string" do
    webservice = Webservice.new(:title => "web", :base_url => "url", :rule_scheme => "asdf")
    webservice.should_not be_valid
    webservice.errors.on(:rule_scheme).should_not be_nil
  end
  
  it "should correctly not transform blank string" do
    webservice = Webservice.create!(:title => "web", :base_url => "url", :rule_scheme => "")
    webservice.load!
    webservice.parameters.should == {}
  end
  
  it "should correctly transform special parameters" do
    webservice = Webservice.create!(:title => "web", :base_url => "url", :rule_scheme => rules)
    webservice.load!(
      :frequency => 'daily',
      :name => 'cosmic-calendar',
      :sign => 'aries',
      :date => 'today'
    )
    webservice.parameters.should == { 
      :content_type => 'cosmic_calendar',
      :sign => 'aries',
      :date => (Date.today).strftime("%m/%d/%Y")
    }
  end
  
  it "should correctly transform special parameters" do
    webservice = Webservice.create!(:title => "web", :base_url => "url", :rule_scheme => rules)
    webservice.load!(
      :frequency => 'daily',
      :name => 'overview',
      :sign => 'taurus',
      :date => 'yesterday'
    )
    webservice.parameters.should == { 
      :content_type => 'daily_overview',
      :sign => 'taurus',
      :date => (Date.today - 1.day).strftime("%m/%d/%Y")
    }
  end
  
  it "should make remote call to webservice" do
    webservice = Webservice.create!(
      :title => "Geocoder", 
      :base_url => 'http://maps.google.com/maps/geo',
      :rule_scheme => "q:\n  - value: boguchany\noutput:\n  - value: xml\nkey:\n  - value: abcdefg"
    )
    webservice.load!
    webservice.get_data!
    webservice.data.at(
      './/xmlns:LatLonBox', webservice.data.root.namespaces
    ).attributes['north'].to_s.should == '58.3829695'
  end
  
  it "should return nil if webservice is unaccessible" do
    webservice = Webservice.create!(
      :title => "Geocoder", :base_url => 'http://blabla', :rule_scheme => "q:\n  - value: bla"
    )
    webservice.load!
    webservice.get_data!
    webservice.data.should be_nil
  end
  
  it "should select value of node from data" do
    webservice = Webservice.create!(
      :title => "Geocoder", 
      :base_url => 'http://maps.google.com/maps/geo',
      :rule_scheme => "q: boguchany\noutput: xml\nkey: abcdefg"
    )
    webservice.load!
    webservice.get_data!
    webservice.get_value(".//xmlns:coordinates").should == "97.4598388,58.3798219,0"
  end
  
end