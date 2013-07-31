class StaticPage < ActiveRecord::Base
  attr_accessible :content, :page_name, :title, :updated_by,:created_by
  PAGE_NAMES = ['about','support']
end
