class SurveyInstancesController < ApplicationController
  def index
    if params[:survey_template_id]
      respond_with survey_template_instances, each_serializer: Plain::SurveyInstanceSerializer
    elsif params[:due]
      respond_with due_instances.not_missed, each_serializer: Plain::SurveyInstanceSerializer
    else
      head :unprocessable_entity
    end
  end

  def show
    respond_with survey_instance
  end

  def top_due
    respond_with top_due_survey_instance
  end

  private

  def survey_instance
    current_organization.survey_instances.find(params[:id]).tap do |instance|
      instance_owner = instance.organization_membership
      owner_or_managed = instance_owner == current_organization_membership || instance_owner.managed_by?(current_organization_membership)
      raise ActiveRecord::RecordNotFound unless owner_or_managed
    end
  end

  def survey_template_instances
    survey_template = current_organization.survey_templates.find(params[:survey_template_id])
    current_organization_membership.survey_instances.where(survey_template: survey_template).order(due_at: :desc)
  end

  def due_instances
    current_organization_membership.survey_instances.due.order(due_at: :asc)
  end

  def top_due_survey_instance
    due_instances.first || (raise ActiveRecord::RecordNotFound)
  end
end
