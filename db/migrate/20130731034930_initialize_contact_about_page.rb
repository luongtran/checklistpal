class InitializeContactAboutPage < ActiveRecord::Migration
  def up
    remove_column :static_pages, :active
    StaticPage.create(:page_name => "About Page", :title => "About Us", :content => "About us content here ...")
    StaticPage.create(:page_name => "Support Page", :title => "Support", :content => "Support content here ...")
  end

  def down
  end
end
