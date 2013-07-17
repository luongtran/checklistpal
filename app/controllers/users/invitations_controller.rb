class Users::InvitationsController < Devise::InvitationsController

  def new
    build_resource
    render :new
  end
  # POST /resource/invitation
  def create
    self.resource = resource_class.invite!(resource_params, current_inviter)
    if resource.last_sign_in_at != "" ||  resource.last_sign_in_at != nil
      role = Role.find(:first, :conditions => ["name = ?", "free"])
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
    list_team_members = ListTeamMember.find(:all, :conditions => ['invitation_token = ?', params[:invitation_token]])
    logger = Logger.new('log/accept_inviation.log')
    logger.info(Time.now)
    logger.info(list_team_members)

    if list_team_members
      list_team_members.each do |list_team_member|
        list_team_member.update_attributes(:active => true)
        @user_id = list_team_member.invited_id
      end
    end
    @user = User.find(:first, :conditions => ["id = ?",@user_id])
    if @user.last_sign_in_at != nil
      @user.accept_invitation!    
      sign_in :user, @user
      redirect_to my_list_path
    else
      render :edit
    end
  end
  # PUT /resource/invitation
  def update
    ListTeamMember.find(:all, :conditions=>[])
    super
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
  #  def after_accept_path_for(resource)
  #    list_team_member = ListTeamMember.find(:first, :conditions => ['invitation_token = ?', params[:user][:invitation_token]])
  #    if list_team_member
  #      @list = List.find(list_team_member.list_id)
  #      redirect_to list_path(@list)
  #    else
  #      redirect_to my_list_path
  #    end    
  #  end  
  private
  def user_params
    params.require(:user).permit(:invitation_token, :password, :password_confirmation)
  end
end
