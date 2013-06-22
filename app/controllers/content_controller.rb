class ContentController < ApplicationController
  before_filter :authenticate_user!
  
  def member
    authorize! :view, :member, :message => 'Access limited to member subscribers.'
  end
  
  def vipmember
    authorize! :view, :vipmember, :message => 'Access limited to VIP member subscribers.'
  end

end
