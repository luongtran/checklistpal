class HomeController < ApplicationController
  before_filter :authenticate_user!, :only => [:find_invite, :dashboard, :inviting]
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

  def find_users_for_invite
    @user_name = params[:user_name]
    @list_id = params[:list_id]
    @users = User.where('name like ? AND id != ?', "%#{@user_name}%", current_user.id).select("id,name,email")
    respond_to do |format|
      format.js
    end
  end

  def invite_user_by_email
    @invite_email = params[:user_email]
    invite_list = List.where(:id => params[:list_id]).first
    @request_valid = true
    if current_user.email == @invite_email
      @request_valid = false
      return
    end
    if (!invite_list.nil?) && (invite_list.user_id == current_user.id)
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
          @limited = false
          if (current_user.connection_count >= Role.where(:name => 'free').first.max_connections) && (!current_user.connections.include? user.id)
            @limited = true
            return
          end
        end
      end
      #==== End == Check limit connection for free user
      require 'digest/md5'
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
    else
      @request_valid = false
    end

    respond_to do |format|
      format.js
    end

  end

# Find and invite with a selected list
  def find_invite
    @invite_list = List.where(:id => params[:list_id]).first
    if @invite_list.nil? || !@invite_list.belong_to?(current_user) # verify
      flash[:error] = "Request is invalid."
      redirect_to my_list_url
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