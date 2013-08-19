class SessionsController < Devise::SessionsController

  def new
    super
  end

  def create
    if params[:list_save_id] # user want to save
      puts "\n\n_____________user want save list id : #{params[:list_save_id]}"
      temp =  params[:list_save_id].to_i
      if session[:new_lists].include?(params[:list_save_id].to_i)
        puts "\n\n________________Yes, saved list allow"
        session[:list_save_id] = params[:list_save_id]
        session[:let_save] = true
      else
        session[:let_save] = nil
      end
      # if List.find(params[:list_save_id]).user_id

    end
    super

  end

end