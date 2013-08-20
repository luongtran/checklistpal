class StaticPagesController < ApplicationController
  before_filter :authenticate_user!, :only => [:paid_support]

  def about
    @page = StaticPage.where(page_name: 'About Page').first
  end

  def support
    @page = StaticPage.where(page_name: 'Support Page').first
  end

  def paid_support
    if current_user.roles.first.name == 'free'
      redirect_to my_list_url
    end
    @page = StaticPage.where(page_name: 'PAID Support Page').first
  end

  def not_found
    @page = StaticPage.where(page_name: '404 Page').first
    render :status => 404, :formats => [:html]
  end

  def server_error
    @page = StaticPage.where(page_name: '500 Page').first
    render :status => 500, :formats => [:html]
  end
end
