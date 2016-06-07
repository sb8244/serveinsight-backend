class ReviewableSurveysController < ApplicationController
  def index
    respond_with reviewable_surveys
  end

  private

  def reviewable_surveys
    SurveyInstance.
      completed.
      where(organization_membership: current_organization_membership.direct_reports).
      where(reviewed_at: nil).
      order(completed_at: :desc)
  end
end
