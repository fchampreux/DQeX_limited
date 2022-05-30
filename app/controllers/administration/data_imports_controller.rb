class Administration::DataImportsController < AdministrationController
  # Check for active session
  before_action :authenticate_user!

  def new
    @data_import = DataImport.new
  end

  def create
    @data_import = DataImport.new(params[:data_import])
    if @data_import.file.nil?
      render :new, notice: t('.FileNameCannotBeEmpty')
    end
    objects = Parameter.find(@data_import.object_type_id).code.pluralize
    objects_import = "#{objects}Import".classify.constantize
    @imported = objects_import.new(file: @data_import.file, playground: @data_import.playground_id)

    if @imported.save
      #redirect_to "/#{objects.downcase}", notice: t('.ImportedObjects')
      redirect_to root_path, notice: "#{t('.ImportedObjects')}: #{@imported.importation_status}"
    else
      @imported.errors.full_messages.each do |msg|
        puts msg
        @data_import.errors[:base] << msg
      end
      render :new, notice: "#{t('.ImportedObjects')}: #{@imported.importation_status}"
    end
  end


end
