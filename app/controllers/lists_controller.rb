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
        logger = Logger.new('log/list.log')
        logger.info("----USER- ROLE - LISTlimit -----")
        logger.info(@user.email)
        logger.info(@user.roles.first.name)
        logger.info(Role.find(current_user.roles.first.id).max_savedlist)
        logger.info(@user.lists.count)
        if @user.lists.count < Role.find(current_user.roles.first.id).max_savedlist
        @list = List.create({
            :name => params[:list][:name],
            :description => "To do list",
            :user_id => @user.id
          })
            if @list.save
              flash[:notice] = "List create successfuly !"
              redirect_to list_url(@list) 
            else
              flash[:error] = "Can't create list !"
              redirect_to :back
            end
        else
          flash[:notice] = "Could not create more list, Please upgrade you account !!!"
          redirect_to :back
        end        
    end
  end
  
  def show
    @list = List.find(params[:id])
    logger = Logger.new('log/show_list.log')
    logger.info("----------------Log for view List by Id --------------")
    logger.info(@list)
    if current_user.present?   # if user login
        if @list.user_id.present?        # if list not have user_id < public list
          logger.info("----Private list -----")
            if current_user.id != @list.user_id   # if current_user is not owner
                if @list.list_team_members.present?
                @list_team_member = @list.list_team_members.find(:first , :conditions => ['user_id = ? AND list_id =? ', current_user.id ,@list.id ])
                  if !@list_team_member.blank?
                    @owner = User.find(@list.user_id)
                    flash[:notice] = "You are viewing list of #{@owner.email}"
                  end
                end
                flash[:alert] = "You not have permission to view this list !"
                redirect_to my_list_path
            else
              flash[:notice] = "Welcome #{current_user.email} !"
            end
        else
            flash[:notice] = "You  are viewing list of anonymous user "
        end
    else     #if user not login
      if @list.user_id.present?   # if list  have user_id < Private list
        flash[:alert] = "You not have permission to view this list !"
        redirect_to root_path
      else                         # if list not have user_id < Public list
        flash[:notice] = "You  are viewing list of anonymous user !"
      end
    end
  end
  
  
  def edit
    @list = List.find(params[:id])
  end
  
  def destroy
    @list = List.find(params[:id])
    if @list.destroy
      flash[:notice] = "List Deleted"
      redirect_to my_list_url
    else
      flash[:error] = "It just didn't happen for you"
      redirect_to my_list_url
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
    response do |format|
      format.html
    end
  end

 def invite_user
   @list = List.find(params[:list_id])
   @user_email = params[:user_email]
   @user_name = params[:name]
   logger = Logger.new('log/list_invite_user.log')
   logger.info("----List for invite-----")
   logger.info(@list)
   logger.info(@user_name)
   logger.info(@user_email)
   User.invite!(:email => @user_email , :name => @user_name)
   user = User.find(:first, :conditions => ['email = ?', @user_email])
   #if !user.blank?
     list_team_member = ListTeamMember.new({:user_id => user.id, :list_id => @list.id, :active => false, :invitation_token =>	user.invitation_token})
     list_team_member.save
   #end


   render :json => {:success => true}
 end

 # def check_permission
 #  @user = current_user
 #  @list = List.find(params[:list_id])
 #   if @list
 # end
  
end
