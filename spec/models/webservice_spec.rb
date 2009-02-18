require File.dirname(__FILE__) + '/../spec_helper'

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

  it "should correctly transform special parameters" do
    webservice = Webservice.create!(:title => "web", :base_url => "url", :rule_scheme => rules)
    webservice.load(
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
    webservice.load(
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
  
end