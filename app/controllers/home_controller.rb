class HomeController < ApplicationController
  before_filter :authenticate_user!, :only => [:find_invite, :invite, :invite_user_by_id, :search_my_connect]
  require 'securerandom'

  def index
    random_string = SecureRandom.urlsafe_base64
    if !current_user
      @list = List.create({
                              :name => "Name of List",
                              :description => "To do list",
                              :slug => random_string
                          })
      if @list.save
        redirect_to list_url(@list.slug)
      else
        flash[:error] = "Could not post list"
      end
    else
      @user = current_user
      num_list = !@user.lists.blank? ? @user.lists.count : 0
      if num_list < Role.find(current_user.roles.first.id).max_savedlist
        @list = List.create({
                                :name => "Name of List",
                                :description => "To do list",
                                :user_id => @user.id,
                                :slug => random_string
                            })
        if @list.save
          redirect_to list_url(@list.slug)
        else
          flash[:error] = "Can't create list !"
          return false
        end
      else
        flash[:notice] = %Q[Please <a href="/users/edit">upgrade</a> your plan to create more lists!].html_safe
        redirect_to my_list_path
      end
    end
  end

  def find_invite
    if !User.list_create(current_user.id, params[:list_id])
      redirect_to my_list_path
    end
    @list_id = params[:list_id]
    @list = List.find(@list_id)
    @list_team_members = current_user.list_team_members.find(:all, :conditions => ["list_id = ? AND active = ?", @list_id, true])
    user_ids = []
    if @list_team_members
      @list_team_members.each do |member|
        user_ids += [member.invited_id]
      end
      if !user_ids.empty?
        @my_connects = User.where('id IN (?)', user_ids)
      end
    end
  end

  def pass_parametter
    @list_ids = params[:list]
    @list_id = JSON.parse(@list_ids)
    session[:list_ids] = @list_id;
    render :json => {
        :location => url_for(:controller => 'home', :action => 'find_multi_invite')
    }
  end

  def find_multi_invite
    @list_ids = session[:list_ids]
    @lists = List.where('id IN (?)', @list_ids)
    user_ids = []
    @lists.each do |list|
      @list_team_members = current_user.list_team_members.find(:all, :conditions => ["list_id = ? AND active = ?", list.id, true])
      if @list_team_members
        @list_team_members.each do |member|
          user_ids += [member.invited_id]
        end
      end
    end
    if !user_ids.empty?
      @my_connects = User.where('id IN (?)', user_ids)
    end
  end

  def search_my_connect
    if !User.list_create(current_user.id, params[:list_id])
      redirect_to my_list_path
    end
    @list_id = params[:list_id]
    @list = List.find(@list_id)
    @user_email = params[:user_email_find]
    @list_team_members = current_user.list_team_members.find(:all, :conditions => ["list_id = ? AND active = ?", @list_id, true])
    user_ids = []
    if @list_team_members
      @list_team_members.each do |member|
        user_ids += [member.invited_id]
      end
      if !user_ids.empty?
        @my_connects = User.where('id IN (?) AND email like ?', user_ids, @user_email)
        if @my_connects.length > 0
          @success = true
        else
          @success = false
        end
      end
    end
    respond_to do |format|
      format.js
    end
  end

  def invite_multi
    @success = false

    #invite by usename or email
    @invite_yourself = false
    invite_email = params[:user_email]
    invite_name = params[:user_name]
    if invite_email == current_user.email
      @invite_yourself = true
      return
    end


    condition = ""
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
    #  @users = User.where(:conditions => condition)

    @users -= [current_user]

    if @users.length > 0

      @has_list_users = true
      puts "@has_list_users = true"
    else
      puts "@has_list_users = false"
      num_connect = User.number_connect(current_user)
      #if User.already_connect(current_user, @user)
      #if (!invite_email.blank?)
      #  @user = User.new({:email => invite_email})
      #  role = Role.find(:first, :conditions => ["name = ?", "free"])
      #  #role = Role.where(:conditions => ["name = ?", "free"]).first;
      #  @user.add_role(role.name)
      #  @user.save
      #  @user.invite!(current_user)
      #  @list_ids = session[:list_ids]
      #  @lists = List.where('id IN (?)', @list_ids)
      #  puts "______#{@lists.count}____"
      #  @lists.each do |list|
      #    if (!ListTeamMember.is_existed_in_connection(current_user.id, list.id, @user.id))
      #      if current_user.list_team_members.create({:invited_id => @user.id, :list_id => list.id, :active => false, :invitation_token => @user.invitation_token})
      #        @success = true
      #      end
      #    end
      #  end
      #end
      #else
      if num_connect < Role.find(current_user.roles.first.id).max_connections
        if (!invite_email.blank?)
          @user = User.new({:email => invite_email})
          @user.add_role('free')
          #@user.save
          @user.invite!(current_user)
          @list_ids = session[:list_ids]
          @lists = List.where('id IN (?)', @list_ids)
          @lists.each do |list|
            if current_user.list_team_members.new({:invited_id => @user.id, :list_id => list.id, :active => false, :invitation_token => @user.invitation_token}).save
              @success = true
            end
          end
        end
      else
        @has_over_connect = true
      end
      #end
    end
    respond_to do |format|
      format.js
    end

  end

  def invite
    if !User.list_create(current_user.id, params[:list_id])
      redirect_to my_list_path
    end
    @success = false
    invite_email = params[:user_email]
    invite_name = params[:user_name]
    condition = ""

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
            @message = "The list already sharing for #{@user.email}"
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

  def invite_user_by_id_multi_list
    @user = User.find(params[:user_id])
    @list_ids = session[:list_ids]
    @lists = List.where('id IN (?)', @list_ids)
    @message = ""
    if @user && @lists
      @user.skip_stripe_update = true
      @user.invite!(current_user)
      @lists.each do |list|
        if (!ListTeamMember.is_existed_in_connection(current_user.id, list.id, @user.id))
          if current_user.list_team_members.new({:invited_id => @user.id, :list_id => list.id, :active => false, :invitation_token => @user.invitation_token}).save
            @success = true
            @message = "Invitation sent to #{@user.email}"
          end
        else
          @message = "The list already sharing for #{@user.email}"
        end
      end
    else
      @message = "Invited failer"
    end
    @success = false
    respond_to do |format|
      format.js
    end
  end

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
            @message = "The user #{@user.email} already existed in your connections"
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