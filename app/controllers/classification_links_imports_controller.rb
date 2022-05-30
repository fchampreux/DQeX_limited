class ClassificationLinksImportsController < ApplicationController
  # Check for active session
  before_action :authenticate_user!

  def new
    @classification = Classification.find(params[:classification_id])
    @classification_links_import = ClassificationLinksImport.new
  end

  def create
    @classification = Classification.find(params[:classification_id])
    @classification_links_import = ClassificationLinksImport.new(params[:classification_links_import])

    if @classification_links_import.save
      #redirect_to @classification, notice: t('ImportedObjects')
      redirect_to @classification, notice: "#{t('ImportedLinks')}: #{@classification_links_import.links_counter} #{t('LinksInserted')}"
    else
      @classification_links_import.errors.full_messages.each do |msg|
        puts msg
        @classification.errors[:base] << msg
      end
      render :new
    end
  end


end
