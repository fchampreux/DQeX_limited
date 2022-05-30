class SkillsImportsController < ApplicationController
  # Check for active session
  before_action :authenticate_user!

  def new
    @business_object = BusinessObject.find(params[:deployed_object_id])
    @skills_import = SkillsImport.new
  end

  def create
    @business_object = BusinessObject.find(params[:deployed_object_id])
    @skills_import = SkillsImport.new(params[:skills_import])
    if @skills_import.save
      redirect_to deployed_object_path(@business_object), notice: t('ImportedBOSks')
    else
      render :new
    end
  end

end
