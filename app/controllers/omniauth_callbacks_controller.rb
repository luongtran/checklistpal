class OmniauthCallbacksController < Devise::OmniauthCallbacksController
  before_filter :logging

  def all
    logger = Logger.new('log/facebook.log')
    logger.info('All function')
    omni = request.env["omniauth.auth"]
    user = User.from_omniauth(omni)
    auth = Authentication.from_omniauth(omni)
    if user.persisted?
      flash[:notice] = "Signed in!"
      sign_in_and_redirect user
    else
      session["devise.user_attributes"] = user.attributes
      redirect_to new_user_registration_url
    end
  end

  alias_method :facebook, :all

  def facebook
    logger = Logger.new('log/facebook.log')
    logger.info('Facebook function')
    user = User.find_for_facebook_oauth(request.env["omniauth.auth"], current_user)
    if user.persisted?
      sign_in_and_redirect user, :event => :authentication #this will throw if @user is not activated
      set_flash_message(:notice, :success, :kind => "Facebook") if is_navigational_format?
    else
      logger = Logger.new('log/facebook.log')
      logger.info("redirect_to new_user_registration_url")
      @logger.info('new user cant saved')
      @logger.infor("Can't register with facebook account: email #{omni['extra']['raw_info'].email} has been taken")
      flash[:alert] = "Can't register with your facebook account: email has already been taken !"
      session["devise.user_attributes"] = user.attributes
      redirect_to new_user_registration_url
    end
  end

  private
  def logging
    logger = Logger.new('log/facebook.log')
    logger.info('\n ------ OmniauthCallbacksController : \n')
  end
end
