class ReviewableSurveysController < ApplicationController
  class TemplatedSurveyInstanceSerializer < SurveyInstanceSerializer
    has_one :survey_template, serializer: Plain::SurveyTemplateSerializer
    has_one :organization_membership, serializer: Plain::OrganizationMembershipSerializer
  end

  def index
    respond_with reviewable_surveys, each_serializer: TemplatedSurveyInstanceSerializer
  end

  private

  def reviewable_surveys
    SurveyInstance.
      completed.
      where(organization_membership: current_organization_membership.direct_reports).
      where(reviewed_at: nil).
      order(completed_at: :asc)
  end
end
