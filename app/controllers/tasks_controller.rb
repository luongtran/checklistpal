class TasksController < ApplicationController  
  before_filter :find_list, :except => [:sort]
  respond_to :js
  
  def create
    @task = @list.tasks.new(params[:task])
    if @task.save
      flash[:notice] = "Task Created"
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
    if @task.update_attributes({ completed: true }) 
      @success = 1
    else
      @success = 0
    end
    respond_with @list, @task, @success
  end
  
  def incomplete
    @task = @list.tasks.find(params[:id])
    if @task.update_attributes({ completed: false })
      @success = 1
    else
      @success = 0
      respond_with @list , @task, @success
    end
  end
  
  def hasduedate
    @task = @list.tasks.find(params[:id])
      if @task.update_attributes({ hasduedate: true })
        @success = 1
      else
        @success = 0
      end
      respond_with @list , @task , @success
  end
  
  def noduedate
    @task = @list.tasks.find(params[:id])
      if @task.update_attributes({ hasduedate: false })
        @success = 1
      else
        @success = 0
      end
      respond_with @list , @task , @success
  end
  
  def due_date
    @task = @list.tasks.find(params[:id])
    if @task.update_attributes({
          :due_date => params[:due_date_value]
        })
      @success = 1
    else
      @suceess = 0
      respond_with @list, @task, @success
    end
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
    if @task.destroy
      @success = 1
    else
      @success = 0
    end
    respond_with @list , @task , @success
  end

  private
  def find_list
    @list = List.find(params[:list_id])
  end
end
