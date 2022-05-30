module CsvHelper
  def to_csv
    CSV.generate(:col_sep => ";") do |csv| #Could accept a separator option
      csv << column_names
      all.each do |column|
        csv << column.attributes.values_at(*column_names)
      end
    end
  end
end