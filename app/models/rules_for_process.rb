# == Schema Information
#
# Table name: rules_for_processes
#
#  id                  :bigint           not null, primary key
#  playground_id       :bigint
#  business_rule_id    :bigint
#  business_process_id :bigint
#  data_policy_id      :bigint
#

class RulesForProcess < ApplicationRecord
  belongs_to :business_rule
  belongs_to :data_policy
end
