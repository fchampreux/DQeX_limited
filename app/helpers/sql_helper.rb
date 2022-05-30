module SqlHelper
include TranslationsHelper

  def getColList(technology, *mode)
    mode[0] ||= 'simple'
    self.deployed_skills.visible.order(:code).map do |v|
      column = v.code
      type = getDataTypes(technology).find{ |x| x["code"] == v.skill_type.code }.alternate_code
      syntax = getDataTypes(technology).find{ |x| x["code"] == v.skill_type.code }.alias
      cast = getDataTypes(technology).find{ |x| x["code"] == v.skill_type.code }.abbreviation
      size = case syntax
        when /\(n,p/ #Size and precision
          specification = "(#{v.skill_size || '*'}, #{v.skill_precision || 0})"
        when /\(n/ #Size
          specification = "(#{v.skill_size || 255 })"
        when /format/ #Explicit formatting
          specification = " #{syntax} "
        else nil
      end
      case mode[0]
        when 'simple'
          item = column
        when 'typed'
          item = "#{column} #{type}#{size}"
        when 'converted'
          if cast.index('(n)')
            item = cast.gsub('table_column', column).gsub('(n)', v.skill_size.to_s)
          else
            item = cast.gsub('table_column', column)
          end
        else nil
      end
    end.join(',--')
  end

  def getDataTypes(technology)
    list = ValuesList.where(resource_name: technology).first
    data_types = list.values
  end

  # Get the list of variables which are assigned the Dimension role : these variables compse the primary Key
  # The return format is either a come separated list, either a concatenated list of variables
  def getPkList(*format)
    format[0] ||= 'list'
    separator = format[0] == 'list' ? ' , ' : ' || '
    self.deployed_skills.where(skill_role_id: 88).map {|skill| skill.code}.join(separator)
    #self.deployed_skills.where(skill_role_id: options_for('skill_roles').find { |x| x["code"] == "DIM" }.id || 0).map {|skill| skill.code}.join(separator)
  end

  # Get the values of a values_list based on its code ! Does Not Evaluate Version !
  def getValues(list)
    ValuesList.find_by(code: list).values
  end

# Get the list of values_lists referenced by the business object
  def getLookupsList
    list_of_lookups = Array.new
    self.deployed_skills.where("values_list_id is not null").each do |skill|
      list_of_lookups << skill.values_list.code unless list_of_lookups.include?(skill.values_list.code)
    end
    list_of_lookups
  end
end
