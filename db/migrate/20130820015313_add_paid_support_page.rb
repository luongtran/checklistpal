class AddPaidSupportPage < ActiveRecord::Migration
  def up
    StaticPage.create(:page_name => "PAID Support Page", :title => "PAID Members Support", :content => "PAID Members support content here ...")
  end

  def down
  end
end
