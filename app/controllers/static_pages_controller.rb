class StaticPagesController < ApplicationController
  def about
    #@page = StaticPage.find(:first , :conditions => ["page_name = ? ",'About'])
    @page = StaticPage.where(page_name: 'About Page').first
  end
  def support
    #@page = StaticPage.find(:first , :conditions => ["page_name = ? ",'Support'])
    @page = StaticPage.where(page_name: 'Support Page').first
  end
end
