class ContentController < ApplicationController
  before_filter :authenticate_user!
  
  def member
    authorize! :view, :free , :message => 'Access limited to Free subscribers.'
  end
  
  def vipmember
    authorize! :view, :paid , :message => 'Access limited to Paid subscribers.'
  end

end
