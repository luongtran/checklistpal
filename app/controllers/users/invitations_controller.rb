class Users::InvitationsController < Devise::InvitationsController
  skip_before_filter :require_no_authentication, :only => :edit
  skip_before_filter :resource_from_invitation_token, :only => [:edit, :update]

  def new
    puts "\n_____________InvitationControllers New"
    build_resource
    render :new
  end

  # POST /resource/invitation
  def create
    puts "\n______________InvitationControllers create"
    self.resource = resource_class.invite!(resource_params, current_user)
    if resource.sign_in_count = 0
      role = Role.where(name: 'free').first
      resource.add_role(role.name)
      resource.invitation_limit = role.max_connections
    end
    if resource.errors.empty?
      set_flash_message :notice, :send_instructions, :email => self.resource.email
      respond_with resource, :location => after_invite_path_for(resource)
    else
      respond_with_navigational(resource) { render :new }
    end
  end

  # GET /resource/invitation/accept?invitation_token=abcdef
  def edit
    list_team_member = ListTeamMember.where(invitation_token: params[:invitation_token], :active => false).first
    if list_team_member # list exist and inactive
      owner_user = User.find(list_team_member.user_id)
      if owner_user.has_role 'free'
        if owner_user.connection_count >= Role.where(:name => 'free').first.max_connections
          flash[:error] = "Sorry, the page doesn't exist"
          redirect_to '/404'
          return
        end
      end
      list = List.find(list_team_member.list_id)
      user_id = list_team_member.invited_id
      @user = User.find(user_id)
      if @user.last_sign_in_at != nil
        if !current_user
          list_team_member.update_attributes(:active => true)
          sign_in(:user, @user)
        end
        flash[:notice] = %Q[You has been accepted the invitation from <strong>#{owner_user.name.nil? ? owner_user.email : owner_user.name}</strong>, click <a href="#{list_url(list.slug)}">here</a> to view the list.].html_safe
        redirect_to my_list_path
      else # new user
        @token = params[:invitation_token]
        render :edit
      end
    else #token is not exist or actived
      if current_user
        flash[:error] = "Sorry, the page doesn't exist"
        redirect_to my_list_url
      else
        redirect_to root_url
      end
    end
  end

  # PUT /resource/invitation
  # update  29/08/13
  def update
    # validate invitation_token
    list_team_member = ListTeamMember.where(invitation_token: params[:user][:invitation_token], :active => false).first
    if !params[:user][:password].blank? && (params[:user][:password] == params[:user][:password_confirmation]) && params[:user][:password].length >=6
      @user = User.find(list_team_member.invited_id)
      @user.name = params[:user][:name]
      @user.is_invited_user = true
      @user.skip_stripe_update = true
      @user.save(:validate => false)
      @user.add_role 'free'
      @user.password = params[:user][:password]
      @user.encrypted_password = @user.encrypted_password
      @user.is_invited_user = false
      @user.skip_stripe_update = false
      @user.save(:validate => false)
      @user.update_stripe_for_invited_user
      list_team_member.update_attributes(:active => true)
      flash[:notice] = "Welcome to Tudli.com ! Your account has been created."
      sign_in(:user, @user)
      redirect_to my_list_url
    else
      if params[:user][:password].blank?
        flash[:error] = "Please fill your password"
      else
        if params[:user][:password] != params[:user][:password_confirmation]
          flash[:error] = "Password doesn't match"
        else
          if  params[:user][:password].length < 6
            flash[:error] = "Password must be at least 6 characters"
          end
        end
      end
      @token = params[:user][:invitation_token]
      @user = User.find(list_team_member.invited_id)
      render :edit
    end
  end

  # GET /resource/invitation/remove?invitation_token=abcdef
  def destroy
    resource.destroy
    set_flash_message :notice, :invitation_removed
    redirect_to after_sign_out_path_for(resource_name)
  end

  protected
  def current_inviter
    @current_inviter ||= authenticate_inviter!
  end

  def has_invitations_left?
    unless current_inviter.nil? || current_inviter.has_invitations_left?
      build_resource
      set_flash_message :alert, :no_invitations_remaining
      respond_with_navigational(resource) { render :new }
    end
  end

  def resource_from_invitation_token
    unless params[:invitation_token] && self.resource = resource_class.to_adapter.find_first(params.slice(:invitation_token))
      set_flash_message(:alert, :invitation_token_invalid)
      redirect_to after_sign_out_path_for(resource_name)
    end
  end

  def after_accept_path_for(resource)
    list_team_member = ListTeamMember.find(:first, :conditions => ['invitation_token = ?', params[:user][:invitation_token]])
    if list_team_member
      @list = List.find(list_team_member.list_id)
      list_path(@list)
    else
      my_list_path
    end
  end

  private
  def user_params
    params.require(:user).permit(:invitation_token, :password, :password_confirmation)
  end

end
