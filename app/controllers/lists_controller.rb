class ListsController < ApplicationController
  
 before_filter :authenticate_user!, :only => [:create , :destroy ]
 respond_to :html, :xml, :js
  
  def index
    respond_with(@lists = List.all)
  end
  
  def new
    @list = List.new  
  end
  
  def create
    if !current_user
      @list = List.new(params[:list])
      if @list.save
        flash[:notice] = "List created"
        redirect_to list_url(@list)
      else
        flash[:error] = "Could not post list"
        respond_with(@list, :location => list_url(@list))
      end
    else
      @user = current_user
      if @user.lists.count < Role.find(current_user.roles.first.id).max_savedlist
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
          redirect_to my_list_path
        end
      else
        redirect_to my_list_path flash[:alert] = %Q[Could not create more list, Please <a href="/upgrade">upgrade</a>PAID you account].html_safe
      end        
    end
  end
  
  def show
    if !List.find(:all , :conditions => ["id = ?", params[:id]]).empty?
      @list = List.find(params[:id])
      if current_user.present?   # if user login
        if @list.user_id.present?        # if list not have user_id < public list
            if current_user.id != @list.user_id   # if current_user is not owner
                if @list.list_team_members.present?
                @list_team_member = @list.list_team_members.find(:first , :conditions => ['invited_id = ? AND list_id =? ', current_user.id ,@list.id ])
                  if !@list_team_member.blank?                    
                    @owner = User.find(@list.user_id)
                    flash[:notice] = "You are viewing list of #{@owner.email}"
                    return
                  end
                else
                flash[:alert] = "You have no permission to view this list !"
                redirect_to my_list_path
                end
            else
              return
            end
        else
            flash[:notice] = "You  are viewing list of anonymous user "
            return
        end
    else     #if user not login
      if @list.user_id.present?   # if list  have user_id < Private list
        flash[:alert] = "You have no permission to view this list !"
        redirect_to root_path
      else                         # if list not have user_id < Public list
        flash[:notice] = "You  are viewing list of anonymous user !"
        return
      end
    end
    else
      flash[:notice] = "List not exists or deleted !"
      redirect_to root_path
    end
  end

  def edit
    if User.list_create(current_user.id,params[:id])    
    @permission = true
    @list = List.find(params[:id])
      if @list.update_attributes(params[:list])
        @success = 1
      else
        @success = 0
      end        
    else    
      flash[:alert] = "You have no permission to edit this list"
      @permission = false
    end
      respond_to do |format|
      format.json { render :json => {:success => @success, :list => @list , :permission => @permission}}   
      end
  end
  
  def destroy
    @list = List.find(params[:id])
    if current_user.id == @list.user_id 
      @list.destroy
      flash[:notice] = "List Deleted"
      redirect_to my_list_url
    else
      flash[:error] = "Can't delete list"
      redirect_to root_path
    end
  end
  def update
    @list = List.find(params[:id])
    if @list.update_attributes(params[:list])
      flash[:notice] = "List updated"
      respond_with(@list, :location => list_url(@list))
    else
      flash[:error] = 'Something is Awry :('
      redirect_to edit_list_path(@list)
    end
  end
  
  def mylist
    @user = current_user
    @lists = List.find(:all, :conditions => ["user_id = ?" ,@user.id])
    @list_team_members = ListTeamMember.find(:all, :conditions => ["invited_id = ? AND active = ?", @user.id , true])
    list_ids = []
    if @list_team_members
      @list_team_members.each do |member|
        list_ids += [member.list_id]
      end
      if !list_ids.empty?
        @friend_lists = List.where('id IN (?)',list_ids)	  	
      end
    end 
    response do |format|
      format.html
    end
  end
  def search_my_list
    @user = current_user
    @list_name = params[:list_name]
    @lists = List.find(:all, :conditions => ["user_id = ? AND name like ?" ,@user.id,"%#{@list_name}%"])
    if @lists.length > 0
      @success = true
    else
      @success = false
    end
    response do |format|
      format.js
    end
  end
end
