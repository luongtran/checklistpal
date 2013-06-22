class ListsController < ApplicationController
  
  respond_to :html, :xml, :js
  
  def index
    respond_with(@lists = List.all)
  end
  
  def new
    @list = List.new  
  end
  
  def create
    @list = List.new(params[:list])
    if @list.save
      flash[:notice] = "List created"
      redirect_to list_url(@list)
    else
      flash[:error] = "Could not post list"
      respond_with(@list, :location => list_url(@list))
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
      redirect_to lists_url
    else
      flash[:error] = "It just didn't happen for you"
      redirect_to lists_url
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
end
