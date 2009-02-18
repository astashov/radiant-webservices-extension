class CreateWebservices < ActiveRecord::Migration
  def self.up
    create_table :webservices do |t|
      t.string :base_url, :null => false
      t.string :title, :null => false
      t.string :description
      t.text :rule_scheme
      
      t.timestamps
    end
  end

  def self.down
    drop_table :webservices
  end
end