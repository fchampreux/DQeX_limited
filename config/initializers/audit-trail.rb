# Configuring audit trail feature based on Audited gem

Audited.config do |config|
  config.audit_class = AuditTrail
end

# Audit trail length
Audited.max_audits = 10 # Keep only the last 10 actions on an object
