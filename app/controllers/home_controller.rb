class HomeController < ApplicationController
  before_filter :authenticate_user! , :only => [:find_invite , :invite ]
  def index
    if !current_user
      @list = List.create({
            :name => "Checklist pal",
            :description => "To do list"            
          })
      if @list.save
        flash[:notice] = "List created"
        redirect_to list_url(@list)
      else
        flash[:error] = "Could not post list"
        respond_with(@list, :location => list_url(@list))
      end
    else
      @user = current_user
      num_list = !@user.lists.blank? ? @user.lists.count : 0
      if num_list < Role.find(current_user.roles.first.id).max_savedlist
        @list = List.create({
            :name => "Checklist pal",
            :description => "To do list",
            :user_id => @user.id
          })
        if @list.save
          flash[:notice] = "List create successfuly !"
          redirect_to list_url(@list) 
        else
          flash[:error] = "Can't create list !"
          respond_with(@list, :location => list_url(@list))
        end
      else
        flash[:alert] = "Could not create more list, Please upgrade you account !!!"
        redirect_to my_list_path
      end        
    end
  end
  
  def find_invite
     if !User.list_create(current_user.id,params[:list_id])
      redirect_to my_list_path
     end
    @list_id = params[:list_id]
    @list = List.find(@list_id)
    @list_team_members = current_user.list_team_members.find(:all , :conditions =>["list_id = ? AND active = ?", @list_id , true])    
    logger = Logger.new('log/my_con.log')
    logger.info('-----------My connect - user = ? ---------'+current_user.email)
    logger.info(@my_connects)
    user_ids = []
    if @list_team_members
      @list_team_members.each do |member|
        user_ids += [member.invited_id]
      end
      if !user_ids.empty?
        @my_connects = User.where('id IN (?)',user_ids)
      end
    end    
  end
  
  def invite
    if !User.list_create(current_user.id,params[:list_id])
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
      else if !invite_name.blank?
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
      num_connect = !current_user.list_team_members.blank? ? current_user.list_team_members.count : 0
      if num_connect < Role.find(current_user.roles.first.id).max_connections
        if(!invite_email.blank?)
          @user = User.new({:email => invite_email})
          role = Role.find(:first, :conditions => ["name = ?", "free"])
          @user.add_role(role.name)
          @user.save
          @user.invite!(current_user)
            if current_user.list_team_members.new({:invited_id => @user.id, :list_id => params[:list_id], :active => false, :invitation_token => @user.invitation_token}).save
              @success = true
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
  
  def invite_user_by_id
    if !User.list_create(current_user.id,params[:list_id])
      redirect_to my_list_path      
    else
      @user = User.find(params[:user_id])    
      @message = ""
      if @user
        if(!ListTeamMember.is_existed_in_connection(current_user.id, params[:list_id], @user.id))
          @user.skip_stripe_update = true
          @user.invite!(current_user)
          if current_user.list_team_members.new({:invited_id => @user.id, :list_id => params[:list_id], :active => false, :invitation_token => @user.invitation_token}).save
            @success = true
            @message = "You already sent successfully an invitation email to #{@user.email}"
          end
        else
          @message = "The user #{@user.email} already existed in your connections"
        end
      else
        @message = "User not found"
      end
      @success = false
      respond_to do |format|
        format.js
      end
    end
  end
  
  def friend_list
    @friend_list = ListTeamMember.find(:all,:conditions =>["invited_id = ? ", current_user.id])
  end
end