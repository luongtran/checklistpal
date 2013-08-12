class UsersController < ApplicationController
  before_filter :authenticate_user!
  skip_before_filter  :verify_authenticity_token
  def index
    authorize! :index, @user, :message => 'Not authorized as an administrator.'
    @users = User.all
  end

  def show
    @user = User.find(params[:id])
  end

  def feedback
    puts "\n\n\n___________#{params[:feedback]}"

    Feedback.create(email: current_user.email, content: params[:content])
  end

  def upload_avatar
    current_user.update_avatar(params[:avatar])
    render text: {
        meta: {
            status: 200,
            msg: "OK"
        },
        response: {avatar_url: current_user.avatar_url}
    }.to_json
  end


  def update
    authorize! :update, @user, :message => 'Not authorized as an administrator.'
    @user = User.find(params[:id])
    role = Role.find(params[:user][:role_ids]) unless params[:user][:role_ids].nil?
    params[:user] = params[:user].except(:role_ids)
    if @user.update_attributes(params[:user])
      @user.update_plan(role) unless role.nil?
      redirect_to users_path, :notice => "User updated."
    else
      redirect_to users_path, :alert => "Unable to update user."
    end
  end

  def destroy
    authorize! :destroy, @user, :message => 'Not authorized as an administrator.'
    user = User.find(params[:id])
    unless user == current_user
      user.destroy
      redirect_to users_path, :notice => "User deleted."
    else
      redirect_to users_path, :notice => "Can't delete yourself."
    end
  end
#  def upgrade
#    @user = current_user
#    @role = @user.roles
#    puts @user.roles
#  end
end
