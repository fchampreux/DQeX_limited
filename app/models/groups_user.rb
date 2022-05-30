class GroupsUser < ApplicationRecord

### Validations
  validates :is_principal, uniqueness: { scope: [:group_id, :user_id] }
  validates :group_id, uniqueness: { scope: :user_id }

  belongs_to :users
  belongs_to :groups

end
