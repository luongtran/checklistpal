class HomeController < ApplicationController
  before_filter :authenticate_user!, :only => [:find_invite, :invite, :invite_user_by_id, :search_my_connect, :dashboard]
  require 'securerandom'


  def index
    random_string = SecureRandom.urlsafe_base64
    if current_user.nil?
      @list = List.new(:name => "Name of List", :description => "To do list", :slug => random_string+"")
      if @list.save
        session[:new_lists] ||= []
        session[:new_lists] << @list.id
        redirect_to list_path(@list.slug)
      else
        flash[:error] = "Could not post list"
      end
    else # logged in
      if current_user.can_create_new_list?
        list = current_user.lists.create(:name => "Name of List", :description => "To do list", :slug => random_string)
        if list.save
          redirect_to list_url(list.slug)
        else
          flash[:error] = "Can't create list !"
          return false
        end
      else
        flash[:error] = %Q[Please <a href="#{my_account_path(:action => 'upgrade')}">upgrade</a> your plan to create more lists].html_safe
        redirect_to my_list_url
      end
    end
  end

  def dashboard

  end

  # Inviting page
  def inviting
    @mylists = current_user.lists
    if @mylists.blank?
      flash[:notice] = "You must create at least one list before invite to someone!"
      redirect_to :back and return
    end
  end

  # Call from Ajax.
  # Params : list id, username or email
  # Find user in system by username or email, if email does not exist -> create new user and send an invite email
  # Created 7/8/13
  #def find_and_invite
  #  #if !User.list_create(current_user.id, params[:list_id])
  #  #  redirect_to my_list_path and return
  #  #end
  #  @success = false
  #  @invite_yourself = false
  #  invite_email = params[:user_email]
  #  invite_name = params[:user_name]
  #  if invite_email == current_user.email
  #    @message = "Cant invite yourself!"
  #    return
  #  else
  #    # Check limited connections/list
  #    list = List.find(params[:list_id])
  #    if ListTeamMember.where(list_id: params[:list_id], active: true).count >= current_user.roles.first.max_connections
  #      @message = "You can't invite another user on the list!"
  #      return
  #    else
  #      # find user by username or email
  #      condition = ""
  #      if !invite_email.blank? && !invite_name.blank?
  #        condition = ["email = ? OR name like ?", "%#{invite_email}%", "%#{invite_name}%"]
  #      else
  #        if !invite_email.blank?
  #          condition = ["email = ?", "%#{invite_email}%"]
  #        else
  #          if !invite_name.blank?
  #            condition = ["name like ?", "%#{invite_name}%"]
  #          end
  #        end
  #      end
  #      @users = User.find(:all, :conditions => condition)
  #      @users -= [current_user] #  Results searching
  #      if @users.count > 0
  #        @success = true
  #        return
  #      else
  #        @message = "No result match !"
  #        return
  #      end
  #
  #      # Check user already connection with the list
  #
  #    end
  #
  #
  #  end
  #
  #
  #  @list_id = params[:list_id]
  #
  #  if @users.count > 0
  #    @has_list_users = true
  #  else
  #    if (!invite_email.blank?)
  #      @user = User.new({:email => invite_email})
  #      @user.add_role('free')
  #      @user.invite!(current_user)
  #      if (!ListTeamMember.is_existed_in_connection(current_user.id, @list_id, @user.id))
  #        if current_user.list_team_members.new({:invited_id => @user.id, :list_id => params[:list_id], :active => false, :invitation_token => @user.invitation_token}).save
  #          @success = true
  #        end
  #      else
  #        @success = false
  #        @message = "The list already invited for #{@user.email}"
  #      end
  #    end
  #  end
  #  respond_to do |format|
  #    format.js
  #  end
  #end

  def find_and_invite
    if !User.list_create(current_user.id, params[:list_id])
      redirect_to my_list_path
    end
    @success = false
    @invite_yourself = false
    invite_email = params[:user_email]
    invite_name = params[:user_name]
    condition = ""
    if invite_email == current_user.email
      @invite_yourself = true
      return
    end
    if !invite_email.blank? && !invite_name.blank?
      condition = ["email like ? OR name like ?", "%#{invite_email}%", "%#{invite_name}%"]
    else
      if !invite_email.blank?
        condition = ["email like ?", "%#{invite_email}%"]
      else
        if !invite_name.blank?
          condition = ["name like ?", "%#{invite_name}%"]
        end
      end
    end
    @has_over_connect = false
    # @users = User.find(:all, :conditions => condition)
    @users = User.where(condition)
    @users -= [current_user]
    @list_id = params[:list_id]
    if @users.length > 0
      @has_list_users = true
    else
      num_connect = User.number_connect(current_user)
      if num_connect < Role.find(current_user.roles.first.id).max_connections
        if (!invite_email.blank?)
          @user = User.new({:email => invite_email})
          role = Role.where(name: 'free').first
          @user.add_role(role.name)
          #@user.save
          @user.invite!(current_user)
          if (!ListTeamMember.is_existed_in_connection(current_user.id, @list_id, @user.id))
            if current_user.list_team_members.new({:invited_id => @user.id, :list_id => params[:list_id], :active => false, :invitation_token => @user.invitation_token}).save
              @success = true
            end
          else
            @success = false
            @message = "The list already invited for #{@user.email}"
          end
        end
      else
        @has_over_connect = true
      end
      @has_list_users = false
    end
    respond_to do |format|
      format.js
    end
  end

  # Find and invite with a selected list
  def find_invite
    current_user.lists.find(params[:list_id])
  rescue ActiveRecord::RecordNotFound => e
    redirect_to my_list_url
  end

  def invite
    if !User.list_create(current_user.id, params[:list_id])
      redirect_to my_list_path
    end
    @success = false
    @invite_yourself = false
    invite_email = params[:user_email]
    invite_name = params[:user_name]
    condition = ""
    if invite_email == current_user.email
      @invite_yourself = true
      return
    end
    if !invite_email.blank? && !invite_name.blank?
      condition = ["email like ? OR name like ?", "%#{invite_email}%", "%#{invite_name}%"]
    else
      if !invite_email.blank?
        condition = ["email like ?", "%#{invite_email}%"]
      else
        if !invite_name.blank?
          condition = ["name like ?", "%#{invite_name}%"]
        end
      end
    end
    @has_over_connect = false
    @users = User.find(:all, :conditions => condition)
    @users -= [current_user]
    @list_id = params[:list_id]
    if @users.length > 0
      @has_list_users = true
    else
      num_connect = User.number_connect(current_user)
      if num_connect < Role.find(current_user.roles.first.id).max_connections
        if (!invite_email.blank?)
          @user = User.new(:email => invite_email)
          @user.add_role('free')
          #@user.save
          @user.invite!(current_user)
          if (!ListTeamMember.is_existed_in_connection(current_user.id, @list_id, @user.id))
            if current_user.list_team_members.new({:invited_id => @user.id, :list_id => params[:list_id], :active => false, :invitation_token => @user.invitation_token}).save
              @success = true
            end
          else
            @success = false
            @message = "The list already invited for #{@user.email}"
          end
        end
      else
        @has_over_connect = true
      end
      @has_list_users = false
    end
    respond_to do |format|
      format.js
    end
  end

  # Call after invite a existing user
  def invite_user_by_id
    @message = ""
    if !User.list_create(current_user.id, params[:list_id])
      redirect_to my_list_path
      return
    else
      num_connect = User.number_connect(current_user)
      if num_connect > Role.find(current_user.roles.first.id).max_connections
        @message = %Q[Could not invite more user, Please <a href="/users/edit">upgrade</a> you account].html_safe
        redirect_to my_list_path
        return
      else
        @user = User.find(params[:user_id])
        if @user
          if (!ListTeamMember.is_existed_in_connection(current_user.id, params[:list_id], @user.id))
            @user.skip_stripe_update = true
            @user.invite!(current_user)
            if current_user.list_team_members.new({:invited_id => @user.id, :list_id => params[:list_id], :active => false, :invitation_token => @user.invitation_token}).save
              @success = true
              @message = "Invitation sent to #{@user.email}"
            end
          else
            @message = "This user already existed in your connections"
          end
        else
          @message = "User not found"
        end
      end
      @success = false
    end
    respond_to do |format|
      format.js
    end
  end
end