class Governance::MonitoringPagesController < GovernanceController
# Check for active session
before_action :authenticate_user!
#load_and_authorize_resource

# Display metadata monitoring graphs
def metadata
  @skills_by_theme = skills_by_theme_series
  @skills_by_user = skills_by_user_series
  @skills_by_week = skills_by_week_series
  @skills_by_day = skills_by_day_series
  @top_skills = top_concepts_series
  @flop_skills = flop_concepts_series
  #render json: @skills
end

end
