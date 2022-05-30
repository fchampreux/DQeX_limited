class Governance::AuditTrailsController < GovernanceController
  before_action :authenticate_user!

  # GET /audits
  # GET /audits.json
  def index
    # @audit_trails = AuditTrail.pgnd(current_playground).order(id: :desc).paginate(page: params[:page], per_page: 20)
    @audit_trails = AuditTrail.order(created_at: :desc).paginate(page: params[:page], :per_page => paginate_lines)
  end

end
