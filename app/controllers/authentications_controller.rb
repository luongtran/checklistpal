class AuthenticationsController < ApplicationController
  def index
    @authentications = Authentication.all
  end
  def facebook
    omni = request.env["omniauth.auth"]
    authentication = Authentication.find_by_provider_and_uid(omni['provider'], omni['uid'])
    if authentication
      flash[:notice] = "Logged in Successfully"
      sign_in_and_redirect User.find(authentication.user_id)
    elsif current_user
      token = omni['credentials'].token
      token_secret = ""
      current_user.authentications.create!(:provider => omni['provider'], :uid => omni['uid'], :token => token, :token_secret => token_secret)
      flash[:notice] = "Authentication successful."
      sign_in_and_redirect current_user
    else
      role = Role.find(:first, :conditions => ["name = ?", "free"])
      user = User.new
      user.provider = omni.provider
      user.uid = omni.uid
      user.email = omni['extra']['raw_info'].email
      user.password = Devise.friendly_token[0,20]
      user.apply_omniauth(omni)
      user.add_role(role.name)
      if user.save
        flash[:notice] = "Logged in."
        sign_in_and_redirect User.find(user.id)             
      else
        flash[:alert] = "Email you input already exist !!!"
        session[:omniauth] = omni.except('extra')
        redirect_to new_user_registration_path
      end
    end
  end
  def create
    @authentication = Authentication.new(params[:authentication])
    if @authentication.save
      redirect_to authentications_url, :notice => "Successfully created authentication."
    else
      render :action => 'new'
    end
  end

  def destroy
    @authentication = Authentication.find(params[:id])
    @authentication.destroy
    redirect_to authentications_url, :notice => "Successfully destroyed authentication."
  end
end
