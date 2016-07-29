class Api::PreviousInsightsController < Api::BaseController
  def show
    if survey_template.days_between_due.nil? && insights_for_template.count == 1
      return render json: { error: "one-off" }, status: :unprocessable_entity
    end

    respond_with :api, insights_for_template, each_serializer: Plain::SurveyInstanceSerializer
  end

  private

  def survey_instance
    @survey_instance ||= current_organization.survey_instances.find(params.fetch(:id)).tap do |instance|
      owner_or_managed = instance.member_has_access?(current_organization_membership)
      raise ActiveRecord::RecordNotFound unless owner_or_managed
    end
  end

  def survey_template
    survey_instance.survey_template
  end

  def insights_for_template
    survey_template.survey_instances.
      where(organization_membership: survey_instance.organization_membership).
      order(iteration: :desc)
  end
end
