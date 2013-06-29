class MyConnectionController < ApplicationController
  before_filter :authenticate_user!
  def invite_connect
    @user = current_user
    @list = List.find(params[:id])
  end
  def create_invite_connect
    @user = current_user
    @list = List.find(params[:id])
    @invite_email = params[:user][:email]
    @invite_user = User.find(:all,:conditions => ["email = ?",@invite_email])
    
    logger = Logger.new("log/invite.log")
    logger.info("---Email for invite---")
    logger.info(@invite_user)
    if(@invite_user)
      @connections = MyConnection.create({
          :invite_user_id => @invite_user.id,
          :list_id => @list.id, 
          :user_id => @user.id
        })
      if @connections.save
        flash[:notice] = "You has share #{@list.name} to #{(User.find(invite_user_id)).email}"
        redirect_to my_list_path
      else
        flash[:notice] = "Share list error !!!!"
        redirect_to my_list_path
      end
    end
  end
end
