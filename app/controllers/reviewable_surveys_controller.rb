class ReviewableSurveysController < ApplicationController
  def index
    respond_with SurveyInstance.
      completed.
      where(organization_membership: current_organization_membership.direct_reports).
      where(reviewed_at: nil).
      order(completed_at: :asc)
  end
end
