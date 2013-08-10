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
          redirect_to root_path
        else # if list not have user_id < Public list
          return
        end
      end
    else
      flash[:notice] = "List not exists or deleted !"
      redirect_to "static_page/about"
    end

    #respond_to do |format|
    #  format.html # show.html.erb
    #  format.pdf do
    #    render :pdf => "filename", :stylesheets => ["application"], :layout => "application"
    #  end
    #end
  end

  def to_pdf
    list = List.find(params[:list])
  end

  def download_pdf
    #require 'pdfcrowd'

=begin
<div class="checkbox">
          <span class="mark" title="Mark completed">
            <form accept-charset="UTF-8" action="/lists/714/tasks/69/complete" data-remote="true" method="post"><div style="margin:0;padding:0;display:inline"><input name="utf8" type="hidden" value="✓"><input name="authenticity_token" type="hidden" value="Gjj5VBjrJQ/tBMlPJo6F73MmWzQhABWSG0HQcKKfWUg="></div>
              <input class="checkbox mark_comp" data_target="714" id="mark_complete" name="mark_complete" type="checkbox" value="69">
</form>          </span>
          <span class="task-des" title="Task name">
             <!-- Render task incompleted -->
              <div class="item-title" id="item_title_69" data-url="/lists/714/tasks/69/edit">asdasd</div>
                      </span>
            <span class="due_date_show hidden">
          </span>
          <span class="number_comment hidden" id="number_comment_69"></span>
        </div>
=end

    list = List.find(params[:list])
    if list
      puts "\n___Download"
      @list = list

      kit = PDFKit.new (_r)
      kit.stylesheets << "#{Rails.root.to_s}/app/assets/stylesheets/application.css"


      ## Get an inline PDF
      #pdf = kit.to_pdf
      # Save the PDF to a file
      # file = kit.to_file('abc.pdf')
      send_file(kit.to_file('abc.pdf'), :filename => "#{list.name}.pdf", :type => "application/pdf")
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
