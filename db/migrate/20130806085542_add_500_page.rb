class Add500Page < ActiveRecord::Migration
  def up
    StaticPage.create(:page_name => "500 Page", :title => "We're sorry, but something went wrong (500)", :content => "<h3>We're sorry, but something went wrong.</h3>")
  end

  def down
  end
end
