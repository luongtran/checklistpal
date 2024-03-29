class CommentsController < ApplicationController

  def show
    @task = Task.find(params[:task_id])
    @comments = @task.comments.all
    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @comment }
    end
  end

  # GET /comments/new
  # GET /comments/new.json
  def new
#      @task = Task.find(params[:task_id])
#      @task.comments.new(params[:comment])      
    @comment = Comment.new
    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @comment }
    end
  end

  # GET /comments/1/edit
  def edit
    @task = Task.find(params[:task_id])
    @comment = @task.comments.find(params[:id])
    if @comment.update_attributes(params[:comment])
      @success = true
    else
      @success = false
    end
    #@comment = Comment.find(params[:id])
    respond_to do |format|
      format.js
    end
  end

  # POST /comments
  # POST /comments.json
  def create
    @success = false
    @task = Task.find(params[:task_id])
    if @task.comments.new(:user_id => current_user.id, :task_id => @task.id, :content => params[:content]).save
      @success = true
    else
      @success =false
    end
    respond_to do |format|
      format.js
    end
  end

  # PUT /comments/1
  # PUT /comments/1.json
  def update
    @comment = Comment.find(params[:id])

    respond_to do |format|
      if @comment.update_attributes(params[:comment])
        format.html { redirect_to @comment, notice: 'Comment was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @comment.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /comments/1
  # DELETE /comments/1.json
  def destroy
    @comment = Comment.find(params[:id])
    @comment.destroy

    respond_to do |format|
      format.html { redirect_to comments_url }
      format.json { head :no_content }
    end
  end
end
