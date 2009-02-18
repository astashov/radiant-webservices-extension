require File.dirname(__FILE__) + "/../../spec_helper"

describe Admin::WebservicesController do
  integrate_views
  before do
    @webservice = Webservice.create!(
      :title => "Metis", 
      :base_url => 'https://metis.astrology.com/api/content_items',
      :description => "Main Webservice"
    )
    login_as @user
  end
  
  
  it "should get index" do
    get :index
    response.should be_success
    response.body.should include("Metis")
    response.body.should include("https://metis.astrology.com/api/content_items")
    response.body.should include("Main Webservice")
  end
  
  it "should get edit" do
    get :edit, :id => @webservice.id
    response.should be_success
    response.should have_tag("input[value=Metis]")
  end
  
  it "should get new" do
    get :new
    response.should be_success
  end
  
  it "should get remove" do
    get :remove, :id => @webservice.id
    response.should be_success
    response.should have_tag("form[action=#{admin_webservice_path(@webservice.id)}]")
  end
  
  it "should create item" do
    lambda do
      post :create, :webservice => { 
        :title => "Geocode", :base_url => "http://geocoder.google.com"
      }
      response.should redirect_to(admin_webservices_path)
    end.should change(Webservice, :count).by(1)
  end
  
  it "should update item" do
    put :update, :id => @webservice.id, :webservice => { :title => "Metis v2" }
    response.should redirect_to(admin_webservices_path)
    @webservice.reload.title.should == "Metis v2"
  end
  
  it "should remove item" do
    lambda do
      delete :destroy, :id => @webservice.id
      response.should redirect_to(admin_webservices_path)
    end.should change(Webservice, :count).by(-1)
  end
end