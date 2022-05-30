# == Schema Information
#
# Table name: business_hierarchies
#
#  id                 :integer          not null, primary key
#  playground_id      :integer
#  pcf_index          :string
#  pcf_reference      :string
#  hierarchical_level :integer
#  hierarchy          :string
#  name               :string
#  name_en            :string
#  name_fr            :string
#  name_de            :string
#  name_it            :string
#  description        :text
#  description_en     :text
#  description_fr     :text
#  description_de     :text
#  description_it     :text
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  responsible        :string(255)
#  field              :string(255)
#  funding            :string(255)
#

require 'rails_helper'

RSpec.describe BusinessHierarchy, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
