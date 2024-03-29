class RegistrationsController < Devise::RegistrationsController

  def new
    @plan = params[:plan]
    if @plan && ENV["ROLES"].include?(@plan) && @plan != "admin"
      super
    else
      redirect_to signup_options_path, :notice => 'Please select a subscription plan below.'
    end
  end

  def create
    super
    session[:omniauth] = nil unless @user.new_record?
  end

  def update_plan
    if current_user.last_4_digits.nil?
      flash.alert = "You need update credit card for upgrade your plan!"
      redirect_to my_account_path
    else
      @user = current_user
      role = Role.find(params[:user][:role_ids]) unless params[:user][:role_ids].nil?
      if @user.update_plan(role)
        if role.name == 'free'
          msg = ''
          lists_count = @user.lists.count
          max = Role.where(:name => 'free').first.max_savedlist
          if lists_count > max
            List.where(:user_id => current_user.id).all(:order => 'created_at', :limit => (lists_count - max)).each do |l|
              l.destroy
            end
            msg = "#{lists_count - max} list(s) has been deleted!"
          else
          end
        end
        redirect_to my_account_path, :notice => "Your plan has been updated. #{msg}"
      else
        render :edit
      end
    end

  end

  def update_card
    @user = current_user
    @user.stripe_token = params[:user][:stripe_token]
    if @user.update_credit_card
      @user.save
      flash.notice = "Your card has been updated"
    else
      #else
      flash.alert = "The card has been declined!"
      #  render :edit
    end
    redirect_to my_account_path
    #end
  end

  private
  def build_resource(*args)
    super
    if params[:plan]
      resource.add_role(params[:plan])
      if session[:omniauth]
        @user.apply_omniauth(session[:omniauth])
        @user.valid?
      end
    end
  end

  protected
  def after_update_path_for(resource)
    my_account_path
  end
end
