class HomeController < ApplicationController
  before_filter :authenticate_user!, :only => [:find_invite, :invite, :invite_user_by_id, :search_my_connect, :dashboard, :inviting]
  require 'securerandom'
  respond_to :html, :js

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
      if request.fullpath.end_with? 'create_new_list' # request from logged user
        if current_user.can_create_new_list?
          list = current_user.lists.create(:name => "Name of List", :description => "To do list", :slug => random_string)
          redirect_to list_url(list.slug)
        else
          flash[:error] = %Q[Please <a href="#{my_account_path(:action => 'upgrade')}">upgrade</a> your plan to create more lists].html_safe
          redirect_to my_list_url
          return
        end
      else
        redirect_to my_list_url # When user already logged in, redirect from root_path ro my_lists_path
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

  # Edit  27/08/13
  def find_and_invite
    invite_list = List.where(:id => params[:list_id]).first
    @list_id = params[:list_id]
    @request_valid = true
    # verify
    if (!invite_list.nil?) && (invite_list.belong_to? current_user) && (params[:user_email] != current_user.email)
      # check request is find by email or username
      if !params[:user_email].blank? # invite by email
        @invite_email = params[:user_email]
        user = User.where(:email => @invite_email).first
        @limited = false
        #==== Start == Check limit connection for free user
        if current_user.has_role? 'free'
          if user.nil?
            if current_user.connection_count >= Role.where(:name => 'free').first.max_connections
              @limited = true
              return
            end
          else
            if !current_user.connections.include? user.id
              @limited = true
              return
            end
          end
        end
        #==== End == Check limit connection for free user
        require 'digest/md5'
        @already_connection_on_list = false
        if !user.nil? # invite a exist user
                      # check already connected to the list
          if !ListTeamMember.where(:list_id => params[:list_id], :invited_id => user.id, :active => true).first.nil?
            @already_connection_on_list = true
            return
          else
            invitation_token = Digest::MD5.hexdigest("#{Time.now}...#{user.email}")
            create_listteammember current_user, params[:list_id], user, invitation_token
            current_user.send_invitation_email invitation_token, user.email
            @success = true
            return
          end
        else
          @new_user = User.new(:email => @invite_email, :name => @invite_email[0, @invite_email.index('@')])
          @new_user.is_invited_user = true
          @new_user.skip_stripe_update = true
          @new_user.save(:validate => false)
          invitation_token = Digest::MD5.hexdigest("#{Time.now}...#{@new_user.email}")
          create_listteammember current_user, params[:list_id], @new_user, invitation_token
          current_user.send_invitation_email invitation_token, @new_user.email
          @success = true
          return
        end
      else # invite by username
        @user_name = params[:user_name]
        @users = User.where('name like ?', "%#{@user_name}%").limit(5)
      end
    else
      @request_valid = false
    end
    respond_to do |format|
      format.js do
        if !@invite_email.nil?
          render :template => "home/find_and_invite"
        else
          render :template => "home/find_and_invite_by_username"
        end
      end
    end
  end

  # Find and invite with a selected list
  def find_invite
    invite_list = List.where(:id => params[:list_id]).first
    if invite_list.nil? || !invite_list.belong_to?(current_user) # verify
      flash[:error] = "Request is invalid."
      redirect_to my_list_url
    end
  end

  def invite
    #if current_user.lists.find(params[:list_id]).empty?
    #
    #else
    #
    #end
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
    @request_valid = false
    @list = current_user.lists.where(:id => params[:lid]).first
    @user = User.where(:id => params[:uid]).first
    @invite_user_name = @user.name
    if !@list.nil? && !@user.nil? && (@list.user_id == current_user.id)
      @request_valid = true
      puts "\n==-=-=-=-=- VALID"
      if current_user.has_role? 'free'
        if (current_user.connection_count <= Role.where(:name => 'free').first.max_connections) && (current_user.connections.include? @user.id)
        @limited = true
          return
        else
          if !current_user.connections.include? @user.id # not connected with current user
            @limited = true
            return
          end
        end
      end
      require 'digest/md5'
      @already_connection_on_list = false
      if !ListTeamMember.where(:list_id => params[:list_id], :invited_id => @user.id, :active => true).first.nil?
        @already_connection_on_list = true
        return
      else
        invitation_token = Digest::MD5.hexdigest("#{Time.now}...#{@user.email}")
        create_listteammember current_user, params[:lid], @user, invitation_token
        current_user.send_invitation_email invitation_token, @user.email
        @success = true
        return
      end
    else
      @request_valid = false
      return
    end
    #rescue ActiveRecord::RecordNotFound => e
    #  @request_valid = false
    respond_to do |format|
      format.js
    end
  end

  private
  def create_listteammember(owner, list_id, invited_user, invitation_token)
    # delete old inactive invitation
    ListTeamMember.where(:user_id => owner.id, :list_id => list_id, :active => false, :invited_id => invited_user.id).destroy_all
    ListTeamMember.create(:invited_id => invited_user.id,
                          :user_id => owner.id,
                          :list_id => list_id,
                          :active => false,
                          :invitation_token => invitation_token)
  end
end