class ApplicationController < ActionController::Base
  protect_from_forgery
  
  rescue_from CanCan::AccessDenied do |exception|
    redirect_to root_path, :alert => exception.message
  end
  def after_invite_path_for(resource)
    [:after_invite_path_for, :after_accept_path_for].each do |method|
      Devise::InvitationsController.send(:remove_method, method) if ApplicationController.method_defined? method
      end
  end
  def after_sign_in_path_for(resource)
    (session[:"user_return_to"].nil?) ? "/" : session[:"user_return_to"].to_s
  end  
  end
