class Users::InvitationsController < Devise::InvitationsController
  skip_before_filter :require_no_authentication, :only => :edit

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
    list_team_member = ListTeamMember.where(invitation_token: params[:invitation_token]).first # !! need to check params before use

    owner_id = list_team_member.user_id
    owner_user = User.find(owner_id)
    if owner_user.has_role 'free'
      # Check limit perlist
      # members_active_on_list
      if ListTeamMember.where(:list_id => list_team_member.list_id, :active => true).count >= Role.where(:name => 'free').first.max_connections
        flash[:error] = "Sorry, the page doesn't exist"
        redirect_to '404'
        return
      end
    else
    end
    user_id = nil
    if list_team_member
      list_team_member.update_attributes(:active => true)
      user_id = list_team_member.invited_id
    end
    @user = User.find(user_id)
    if @user.last_sign_in_at != nil
      @user.accept_invitation!
      sign_in(:user, @user)
      redirect_to my_list_path
    else # new user
      render :edit
    end
  end

  # PUT /resource/invitation
  def update
    # validate invitation_token
    puts "\n\n__________Chap nhan invite va tao mk"
    super
  end

  #def update
  #  if this
  #    redirect_to root_path
  #  else
  #    super
  #  end
  #end

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
