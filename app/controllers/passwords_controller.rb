class PasswordsController < Devise::PasswordsController
  def create
    usr = User.where(:email => params[:user][:email]).first
    if usr
      if usr.is_facebook_account?
        flash[:error] = "Can't reset password for this email."
        redirect_to new_user_password_url and return
      end
    end
    super
  end
end