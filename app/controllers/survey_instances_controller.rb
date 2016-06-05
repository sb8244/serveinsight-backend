class SurveyInstancesController < ApplicationController
  def index
    if params[:survey_template_id]
      respond_with survey_template_instances, each_serializer: Plain::SurveyInstanceSerializer
    elsif params[:due]
      respond_with due_instances, each_serializer: Plain::SurveyInstanceSerializer
    else
      head :unprocessable_entity
    end
  end

  def show
    respond_with survey_instance
  end

  private

  def survey_instance
    current_organization_membership.survey_instances.find(params[:id])
  end

  def survey_template_instances
    survey_template = current_organization.survey_templates.find(params[:survey_template_id])
    current_organization_membership.survey_instances.where(survey_template: survey_template).order(due_at: :desc)
  end

  def due_instances
    current_organization_membership.survey_instances.due.order(due_at: :asc)
  end
end
