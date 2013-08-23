class AuthenticationsController < ApplicationController

  before_filter :logging

  def index
    @authentications = Authentication.all
  end

  def facebook
    @logger.info('facebook function')
    omni = request.env["omniauth.auth"]
    authentication = Authentication.find_by_provider_and_uid(omni['provider'], omni['uid'])
    if authentication
      flash[:notice] = "Logged in Successfully"
      @user = User.find(authentication.user_id)
      @user.add_role("free")
      sign_in_and_redirect @user #User.find(authentication.user_id)
    elsif current_user
      token = omni['credentials'].token
      token_secret = ""
      current_user.authentications.create!(:provider => omni['provider'], :uid => omni['uid'], :token => token, :token_secret => token_secret)
      flash[:notice] = "Authentication successful."
      sign_in_and_redirect current_user
    else
      @logger.info("New user -> create: info.nickname = #{omni.info.nickname} | omi.extra.username = #{omni['extra']['raw_info'].username} ")
      user = User.new
      user.provider = omni.provider
      user.uid = omni.uid
      user.email = omni['extra']['raw_info'].email
      user.name = omni.info.nickname
      user.avatar_s3_url = omni.info.image
      user.password = Devise.friendly_token[0, 20]
      user.apply_omniauth(omni)
      user.add_role("free")
      user.fb_account = true
      if user.save
        flash[:notice] = "Logged in."
        sign_in_and_redirect User.find(user.id)
      else
        @logger.infor("Can't register with facebook account: email #{omni['extra']['raw_info'].email} has been taken")
        flash[:alert] = "Can't register with your facebook account: email has already been taken !"
        session[:omniauth] = omni.except('extra')
        redirect_to signup_options_url
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

  private
  def logging
    @logger = Logger.new('public/facebook.log')
    @logger.info('\n ------ AuthenticationsController : \n')
  end
end
