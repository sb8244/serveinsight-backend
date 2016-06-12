class ReviewableSurveysController < ApplicationController
  def index
    respond_with reviewable_surveys
  end

  def reports
    relevant_reports = Tree::Reviewer.new(current_organization_membership).indirect_reports
    respond_with reviewable_surveys(member_scope: relevant_reports), include_reviewer: true
  end

  def mark_reviewed
    reviewable_survey.update!(reviewed_at: Time.now)
    head :no_content
  end

  private

  def reviewable_surveys(member_scope: current_organization_membership.direct_reports)
    SurveyInstance.
      completed.
      where(organization_membership: member_scope).
      where(reviewed_at: nil).
      order(completed_at: :desc).
      includes(
        organization_membership: [:reviewer],
        survey_template: [
          {
            questions: [:answers]
          }
        ]
      )
  end

  def reviewable_survey
    current_organization.survey_instances.find(params[:id]).tap do |instance|
      raise ActiveRecord::RecordNotFound unless instance.organization_membership.managed_by?(current_organization_membership)
    end
  end
end
