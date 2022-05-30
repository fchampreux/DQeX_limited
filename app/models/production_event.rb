class ProductionEvent < ApplicationRecord
  ### validations    validates :parent,      presence: true
  	validates :playground_id, presence: true
    belongs_to :parent, class_name: "ProductionGroup", foreign_key: "production_group_id"
    belongs_to :status, class_name: "Parameter", foreign_key: "status_id"	# helps retrieving the status name
    belongs_to :technology, class_name: "Value", foreign_key: "technology_id"	# helps retrieving the status name
    belongs_to :statement_language, class_name: "Parameter", foreign_key: "statement_language_id"	# helps retrieving the language name
    belongs_to :node_type, class_name: "Parameter", foreign_key: "node_type_id"
    belongs_to :production_execution
    belongs_to :task
    belongs_to :target_object, class_name: "BusinessObject", foreign_key: :target_object_id
    belongs_to :failure_next, class_name: "ProductionEvent", foreign_key: :failure_next_id
    belongs_to :success_next, class_name: "ProductionEvent", foreign_key: :success_next_id
    belongs_to :predecessor, class_name: "ProductionEvent", foreign_key: :predecessor_id
    has_one_attached :log_file
    has_many_attached :attachments
end
