class StaticPagesController < ApplicationController

  def about
  end

  def contact
  end

  def administration
      @business_hierarchy_import = BusinessHierarchyImport.new
      @business_objects_import = BusinessObjectsImport.new
      @business_rules_import = BusinessRulesImport.new
      @organisations_import = OrganisationsImport.new
      @territories_import = TerritoriesImport.new
      @business_rules_tasks_import = BusinessRulesTasksImport.new

      # Business object skills
      @business_object = BusinessObject.new
      @skills_import = SkillsImport.new

      # Business rule Tasks
      @business_rule = BusinessRule.new
      #@tasks_import = TasksImport.new
  end

end
