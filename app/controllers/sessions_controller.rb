class SessionsController < Devise::SessionsController

  def new
    puts "\n\n_____________Step 2 : New"
    super
  end

  def create
    puts "\n\n_____________Step 1 : Create"
    if params[:list_save_id] # user want to save
      if List.find(params[:list_save_id]).user_id   # secure save
        session[:let_save] = nil
      else
        session[:list_save_id] = params[:list_save_id]
        session[:let_save] = true
      end
    end
    super
  end

end