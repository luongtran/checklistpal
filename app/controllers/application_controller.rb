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

      if session[:let_save]
        if current_user.can_create_new_list?
          @temp_list = List.find(session[:list_save_id])
          @temp_list.update_attribute(:user_id, current_user.id)
          session[:let_save] = nil
          session[:list_save_id] = nil
          flash[:notice] = %Q[A list has been saved to your lists. Click <a href="#{list_view_path(:slug => @temp_list.slug)}">here</a> to view.].html_safe

        else
          flash[:notice] = "You can't save anymore list, please upgrade your plan !"
        end
      end
      dashboard_path
    end

  end
end
                          