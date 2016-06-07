class ReviewableSurveysController < ApplicationController
  def index
    respond_with reviewable_surveys
  end

  def mark_reviewed
    reviewable_survey.update!(reviewed_at: Time.now)
    head :no_content
  end

  private

  def reviewable_surveys
    SurveyInstance.
      completed.
      where(organization_membership: current_organization_membership.direct_reports).
      where(reviewed_at: nil).
      order(completed_at: :desc)
  end

  def reviewable_survey
    current_organization.survey_instances.find(params[:id]).tap do |instance|
      raise ActiveRecord::RecordNotFound unless instance.organization_membership.managed_by?(current_organization_membership)
    end
  end
end
