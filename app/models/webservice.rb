class Webservice < ActiveRecord::Base
  
  validates_presence_of :base_url, :title
  validates_uniqueness_of :title
  
end