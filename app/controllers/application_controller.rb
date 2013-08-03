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

    if resource.class == AdminUser
      admin_dashboard_path
    else
      my_list_path
    end

  end
end
                          