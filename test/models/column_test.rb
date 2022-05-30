# == Schema Information
#
# Table name: columns
#
#  id                 :integer          not null, primary key
#  name               :string(100)      not null
#  description        :text
#  size               :integer          not null
#  is_key             :boolean          default(FALSE), not null
#  created_by         :string(100)      not null
#  updated_by         :string(100)      not null
#  session_id         :string(100)      not null
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  business_object_id :integer
#  playground_id      :integer
#  is_published       :boolean
#  precision          :integer
#  column_type        :string(20)
#

require 'test_helper'

class ColumnTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
