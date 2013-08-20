class ListsController < ApplicationController
  before_filter :authenticate_user!, :only => [:destroy, :mylist, :edit]
  # after_filter :get_html, :only => [:show]
  respond_to :html, :xml, :js, :pdf

  def show
    @list = List.where(slug: params[:slug]).first
    if !@list.blank?
      if current_user # if user login
        if @list.user_id # if list not have user_id < public list
          if current_user.id != @list.user_id # if current_user is not owner
            if @list.list_team_members.present? # check the list has been shared,  current_user  connect to the list
                                                #list_team_member = @list.list_team_members.find(:first, :conditions => ['invited_id = ? AND list_id =? ', current_user.id, @list.id])
              list_team_member = @list.list_team_members.where(invited_id: current_user.id, list_id: @list.id).first
              # Check current user is connect to the list
              if !list_team_member.blank?
                owner = @list.user
                flash[:notice] = "You are viewing list of #{owner.email}"
                return
              else
                flash[:alert] = "You have no permission to view this list !"
                redirect_to my_list_url and return
              end
            else
              redirect_to my_list_url and return
            end
          else
            return
          end
        else
          return
        end
      else #if user not login
        if @list.user_id.present? # if list  have user_id < Private list
          flash[:notice] = "You have no permission to view this list !"
          redirect_to root_url
        else # if list not have user_id < Public list
          return
        end
      end
    else
      flash[:notice] = "List not exists or deleted !"
    end

    #respond_to do |format|
    #  format.html # show.html.erb
    #  format.pdf do
    #    render :template => 'lists/pdf',
    #           :locals => {:current_list => @list}
    #  end
    #end

  end

  def to_pdf

  end

  def download_pdf
    @list = List.find(params[:lid])
    # Check the list belongs to current_user
    puts "Yes, i known _________"
    #pdf = WickedPdf.new.pdf_from_string(
    #    render_to_string('_pdf.html.erb'),
    #    :layout => false
    #)
    #save_path = Rails.root.join('tmp', "#{@list.id}.pdf")
    #File.open(save_path, 'wb') do |file|
    #  file << pdf
    #end
    #send_file save_path, :type => 'application/pdf'
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
    current_user.lists.find(params[:id]).destroy
    flash[:notice] = "A list has been successfully deleted"
    redirect_to my_list_url
  rescue RecordNotFound => e
    flash[:notice] = "An error has occurred, your request is invalid"
    redirect_to my_list_url


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
    @list_team_members = ListTeamMember.where(:invited_id => current_user.id, active: true)
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

  # Rewrite  19/8/13
  def search_my_list
    #if params[:list_name].length != 0
    keyword = "%#{params[:list_name]}%"
    @lists = current_user.lists.where("lower(name) like ?", keyword.downcase)
    response do |format|
      format.js
    end

  end

  private

  def generate_pdf(client)
    Prawn::Document.new do
      text client.name, :align => :center
      text "Address: #{client.address}"
      text "Email: #{client.email}"
    end.render
  end

  def get_html
    kit = PDFKit.new response, :page_size => 'Letter'
    pdf = kit.to_pdf
    kit.stylesheets << "#{Rails.root.to_s}/app/assets/stylesheets/application.css"
    # Save the PDF to a file
    file = kit.to_file('abc.pdf')
    send_file(file, :filename => "lht.pdf", :type => "application/pdf")
  end
end
