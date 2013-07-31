class StaticPagesController < ApplicationController
  def about
    @page = StaticPage.where(page_name: 'About Page').first
  end
  def support
    @page = StaticPage.where(page_name: 'Support Page').first
  end
end
