class TasksController < ApplicationController  
  before_filter :find_list, :except => [:sort]
  respond_to :js
  
  def create
    @task = @list.tasks.new(params[:task])
      if current_user
      @task.user_id = current_user.id
      logger = Logger.new('log/task_create.log')
      logger.info('---NEW TASK -- user_id ----')
      logger.info(current_user.id)
      logger.info(@task.user_id)
      logger.info(@task.id)
      end
    if @task.save
      flash[:notice] = "Task Created"
      logger.info(@task.id)
    else
      flash[:error] = "It just didn't happen for you"
    end
#    respond_to do |format|
#      format.html
#    end
    #respond_with @list
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
       @task.update_attributes(hasduedate: params[:hasduedate])
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
      @task.update_attributes(due_date: params[:due_date_value])
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
    if current_user.id != @task.user_id
      flash[:alert] = "You not have permission to delete this task !"
      @success = 0
    else
      if @task.destroy
        flash[:notice] = "Task deleted !"
        @success = 1
      else
        @success = 0
      end
    end
    respond_with @list , @task , @success
  end

  private
  def find_list
    @list = List.find(params[:list_id])
  end
end
