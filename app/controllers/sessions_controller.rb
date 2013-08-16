class SessionsController < Devise::SessionsController


  def create
    if params[:user][:list_save_id] # want to save
      session[:list_save_id] = params[:user][:list_save_id]
      session[:let_save] = true
    end
    super
  end

end