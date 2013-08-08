class ListsController < ApplicationController
  before_filter :authenticate_user!, :only => [:destroy, :mylist, :edit]
  respond_to :html, :xml, :js

  def show
    puts "\n___________________BUOC 2"
    @list = List.where(slug: params[:slug]).first
    if !@list.blank?

      if current_user.present? # if user login
        if @list.user_id.present? # if list not have user_id < public list
          if current_user.id != @list.user_id # if current_user is not owner
            if @list.list_team_members.present? # check the list has been shared,  current_user  connect to the list
              @list_team_member = @list.list_team_members.find(:first, :conditions => ['invited_id = ? AND list_id =? ', current_user.id, @list.id])
              if !@list_team_member.blank?
                @owner = User.find(@list.user_id)
                flash[:notice] = "You are viewing list of #{@owner.email}"
                return
              else
                flash[:alert] = "You have no permission to view this list !"
                redirect_to my_list_url and return
              end
            else
              redirect_to my_list_url and return
            end
          end
        else
          return
        end

      else #if user not login
        puts "\n___________________BUOC 3"
        if @list.user_id.present? # if list  have user_id < Private list
          flash[:alert] = "You have no permission to view this list !"
          redirect_to root_path
        else # if list not have user_id < Public list
          return
        end
      end
    else
      flash[:notice] = "List not exists or deleted !"
      redirect_to root_path
    end

  end

  def edit
    if User.list_create(current_user.id, params[:id])
      @permission = true
      @list = List.find(params[:id])
      if @list.update_attributes(params[:list])
        @success = 1
      else
        @success = 0
      end
    else
      @permission = false
    end
    respond_to do |format|
      format.json { render :json => {:success => @success, :list => @list, :permission => @permission} }
    end
  end

  def destroy
    @list = List.find(params[:id])
    if current_user.id == @list.user_id
      @list.destroy
      redirect_to my_list_url notice: "List Deleted"
    else
      redirect_to root_path alert: "Can't delete list"
    end
  end

  def update
    @list = List.find(params[:id])
    if @list.update_attributes(params[:list])
      respond_with(@list, :location => list_url(@list))
    else
      flash[:error] = 'Something is Awry :('
      redirect_to edit_list_path(@list)
    end
  end

  # Edited : 8/8/13
  def mylist
    @lists = current_user.lists
    @list_team_members = ListTeamMember.where(invited_id: current_user.id, active: true)
    list_ids = []
    if @list_team_members
      @list_team_members.each do |member|
        list_ids += [member.list_id]
      end
      if !list_ids.empty?
        @friend_lists = List.where('id IN (?)', list_ids)
      end
    end
    @list_team_members2 = current_user.list_team_members.find(:all, :conditions => ["active = ?", true])
    user_ids = []
    if @list_team_members2
      @list_team_members2.each do |member|
        user_ids += [member.invited_id]
      end
      if !user_ids.empty?
        @my_connects = User.where('id IN (?)', user_ids)
      end
    end
    response do |format|
      format.html
    end
  end

  def remove_connect
    @is_not_connect = false
    @list_id = params[:list_id]
    @user_id = params[:user_id]

    @current_connect = ListTeamMember.find(:all, :conditions => ["list_id = ? and invited_id = ?", @list_id, @user_id])

    if @current_connect.empty?
      @success = false
    else
      @current_connect.each do |f|
        f.destroy
      end
      @success = true
      @is_not_connect = true
      redirect_to my_list_url
    end
  end

  def search_my_list
    @user = current_user
    @list_name = params[:list_name]
    @lists = List.find(:all, :conditions => ["user_id = ? AND name like ?", @user.id, "%#{@list_name}%"])
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
