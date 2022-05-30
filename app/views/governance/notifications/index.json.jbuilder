json.array!(@notifications) do |notification|
  json.extract! notification, :playground_id, :name, :description, :created_by, :updated_by, :owner_id, :severity_id, :scope_id, :business_object_id, :odq_unique_id, :odq_object_id, :expected_at, :closed_at, :responsible_i
  json.url notification_url(notification, format: :json)
end
