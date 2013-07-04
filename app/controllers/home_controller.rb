class HomeController < ApplicationController
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
          redirect_to my_list_path
        end
      else
        flash[:alert] = "Could not create more list, Please upgrade you account !!!"
        redirect_to my_list_path
      end        
    end
  end
end