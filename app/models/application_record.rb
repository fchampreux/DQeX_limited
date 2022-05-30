class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true
  include PgSearch::Model

  # fill-in sort code when created or updated
  before_save :sort_order

  ### scope
  scope :owned_by, ->(user) { where owner_id: user.id }
  scope :visible, -> { where is_active: true }
  scope :pgnd, ->(my_pgnd) { where(playground_id: my_pgnd) unless $Unicity }

  ### full-text local search
  pg_search_scope :search_by_code, against: [:code, :created_by, :updated_by],
    associated_against: { name_translations: [:translation],
                         description_translations: [:translation]},
    using: { tsearch: { prefix: true, negation: true } }

  def self.search(criteria)
    if criteria.present?
      search_by_code(criteria)
    else
      # No query? Return all records, sorted by hierarchy.
      order( :updated_at )
    end
  end

  ### Public functions definitions
  def set_as_inactive(user)
    self.update_attributes(is_active: false, updated_by: user)
  end

  def set_as_active(user)
    self.update_attributes(is_active: true, updated_by: user)
  end

  ### format code with naming convention
  def set_code
    list_id = ParametersList.where("code=?", 'LIST_OF_OBJECT_TYPES').take!
    prefix = Parameter.find_by("parameters_list_id=? AND code=?", list_id, self.class.name ).property
    self.code = "#{code.gsub(/[^0-9A-Za-z]/, '_')}".upcase[0,32]
    # Do not add prefix if it is already present
    if "#{self.code[0, prefix.length]}_" != "#{prefix}_"
      self.code = "#{prefix}_#{self.code}"
    end
  end

  def sort_order
    if self.has_attribute?(:code) and self.has_attribute?(:sort_code)
      if !self.sort_code
        if self.code.to_f.to_s == self.code.to_s || self.code.to_i.to_s == self.code.to_s # Number
          self.sort_code = self.code.rjust(32, '0')
        else
          self.sort_code = self.code
        end
      end
    end
  end


end
