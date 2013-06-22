class HomeController < ApplicationController
  def index
  @list = List.create({
      :name => "Checklist Pal",
      :description => "To do list"
    }) 
  if current_user
    @list.user_id = current_user.id
  end
  @list.save
    redirect_to list_view_path(@list)
  end
end