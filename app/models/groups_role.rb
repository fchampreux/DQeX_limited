class GroupsRole < ApplicationRecord

### Validations
  validates :group_id, uniqueness: { scope: :parameter_id }

  belongs_to :parameter
  belongs_to :group

end
