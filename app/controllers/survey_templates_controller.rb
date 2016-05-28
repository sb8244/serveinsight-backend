class SurveyTemplatesController < ApplicationController
  def index
    respond_with survey_templates
  end

  def show
    respond_with survey_templates.find(params.fetch(:id))
  end

  def create
    respond_with created_template
  end

  def update

  end

  private

  def survey_templates
    current_organization.survey_templates.includes(:questions)
  end

  def created_template
    survey_templates.create(template_params.merge(creator: current_organization_membership)).tap do |template|
      question_params.fetch(:questions, []).each_with_index do |question_param, index|
        template.questions.create(question_param.merge(organization: current_organization, order: index))
      end
    end
  end

  def template_params
    params.permit(:name, :goals_section)
  end

  def question_params
    params.permit(questions: [:question])
  end
end
