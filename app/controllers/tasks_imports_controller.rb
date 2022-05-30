class TasksImportsController < ApplicationController
  # Check for active session
  before_action :authenticate_user!

  def new
    @tasks_import = TasksImport.new
  end

  def create
    @tasks_import = TasksImport.new(params[:tasks_import])
    if @tasks_import.save
      redirect_to tasks_path, notice: t('ImportedTasks')
    else
      render :new
    end
  end

end
