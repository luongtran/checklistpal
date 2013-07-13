class StaticPagesController < ApplicationController
  def about
    @page = StaticPage.find(:first , :conditions => ["page_name = ? ",'About'])
  end
  def support
    @page = StaticPage.find(:first , :conditions => ["page_name = ? ",'Support'])
  end
end
