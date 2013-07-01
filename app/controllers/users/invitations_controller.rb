class Users::InvitationsController < Devise::InvitationsController


  # POST /resource/invitation
  def create
    self.resource = resource_class.invite!(resource_params, current_inviter)
      role = Role.find(:first, :conditions => ["name = ?", "free"])
      resource.add_role(role.name)
      resource.invitation_limit = role.max_connections
    if resource.errors.empty?
      set_flash_message :notice, :send_instructions, :email => self.resource.email
      respond_with resource, :location => after_invite_path_for(resource)
    else
      respond_with_navigational(resource) { render :new }
    end
  end

  # GET /resource/invitation/accept?invitation_token=abcdef
  def edit
    role = Role.find(:first, :conditions => ["name = ?", "free"])
    resource.add_role(role.name)
    resource.invitation_limit = role.max_connections
    render :edit
  end

  # PUT /resource/invitation
  def update
    logger = Logger.new('log/invite_token.log')
    logger.info('--------Log for update invitation-------')
    logger.info(params[:user][:invitation_token])

    @user = User.find(:first, :conditions => ['invitation_token = ?', params[:user][:invitation_token]])
    #if !@user.blank?
      list_team_member = ListTeamMember.find(:first, :conditions => ['user_id = ? AND invitation_token = ?', @user.id, @user.invitation_token])
      list_team_member.active = true
      list_team_member.save

    #end
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
end
