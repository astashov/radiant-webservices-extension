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

end