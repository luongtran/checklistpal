class TasksController < ApplicationController  
  before_filter :find_list, :except => [:sort]
  respond_to :js
  
  def create
    @task = @list.tasks.new(params[:task])
      if current_user
      @task.user_id = current_user.id
      end
      @task.position = 1
    if @task.save
      flash[:notice] = "Task Created"
    else
      flash[:error] = "It just didn't happen for you"
    end
    render :partial => 'lists/items'
  end
  
  def edit
    @task = @list.tasks.find(params[:id])
    if @task.update_attributes(params[:task])
      @success = 1
    else
      @success = 0
    end
    respond_to do |format|
      format.json { render :json => {:success => @success, :task => @task}}
    end
  end
  
  def complete
    @task = @list.tasks.find(params[:id])
    if @task != nil?
     @task.update_attributes({ completed: params[:completed] }) 
      @success = 1
    else
      @success = 0
    end
    respond_with  @task, @success
  end
  
  def hasduedate
    @task = @list.tasks.find(params[:id])    
      if @task != nil?
       @task.update_attributes(:hasduedate => params[:hasduedate])
        @success = 1        
      else
        set_flash "Error, please try again !"
        @success = 0
      end
    respond_with  @task, @success
  end

  def update_due_date
    @task = @list.tasks.find(params[:id])
    if @task != nil?
      @task.update_attributes({:due_date => params[:due_date_value]})
      @success = 1
    else
      flash[:notice] = "can't update due_date"
      @suceess = 0
    end
    respond_with @task,@success
  end
  
  def sort
      params[:task].each_with_index do |id, index|
      Task.update_all(['position=?', index+1], ['id=?', id])
    end
    render :nothing => true
  end
  
  def delete
    @task = @list.tasks.find(params[:id])
    @task_id = @task.id
    if @task.user_id.present?
      if current_user.id != @task.user_id
          if current_user.id == @list.user_id
              if @task.destroy
                @success = 1
              else
                @success = 0
              end
          else
            @success = 0
          end
      else
        if @task.destroy
          @success = 1
        else
          @success = 0
        end
      end
    else
        if @task.destroy
          @success = 1
        else
          @success = 0
        end
    end
    respond_with @list , @task , @success
  end
  
  def show
    @task = @list.tasks.find(params[:id])
  end

  private
  def find_list
    @list = List.find(params[:list_id])
  end
end
