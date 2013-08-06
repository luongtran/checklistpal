class Add404Page < ActiveRecord::Migration
  def up
    StaticPage.create(:page_name => "404 Page", :title => "The page you were looking for doesn't exist (404)", :content => "<h3>The page you were looking for doesn't exist.</h3>")
  end

  def down
  end
end
