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
  
end
