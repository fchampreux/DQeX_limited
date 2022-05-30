class ValuesImportsController < ApplicationController
  # Check for active session
  before_action :authenticate_user!

  def new
    @values_list = ValuesList.find(params[:values_list_id])
    @values_import = ValuesImport.new
  end

  def create
    @values_list = ValuesList.find(params[:values_list_id])
    @values_import = ValuesImport.new(params[:values_import])
    if @values_import.save
      redirect_to values_list_path(@values_list), notice: t('ImportedVs')
    else
      render :new
    end
  end

end
