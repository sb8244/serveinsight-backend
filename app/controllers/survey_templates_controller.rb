class SurveyTemplatesController < ApplicationController
  def index
    respond_with survey_templates
  end

  def show
    respond_with survey_template
  end

  def create
    respond_with created_template
  end

  def update
    update_template
    respond_with survey_template
  end

  private

  def survey_templates
    current_organization.survey_templates.includes(:questions)
  end

  def survey_template
    @survey_template ||= survey_templates.find(params.fetch(:id))
  end

  def created_template
    survey_templates.create(template_params.merge(creator: current_organization_membership)).tap do |template|
      question_params.fetch(:questions, []).each_with_index do |question_param, index|
        template.questions.create(question_param.merge(organization: current_organization, order: index))
      end
    end
  end

  def update_template
    survey_template.update(template_params) if template_params.any?

    if update_question_params.any?
      keep_ids = update_question_params.map { |h| h[:id] }.compact
      survey_template.questions.where.not(id: keep_ids).update_all(deleted: true)
      update_question_params.each_with_index do |question_param, order|
        existing_question = survey_template.questions.find_by(id: question_param[:id])

        if existing_question
          existing_question.update!(question_param.merge(order: order))
        else
          survey_template.questions.create!(question_param.merge(order: order, organization: current_organization))
        end
      end
    end
  end

  def template_params
    params.permit(:name, :goals_section)
  end

  def question_params
    params.permit(questions: [:id, :question])
  end

  def update_question_params
    @update_question_params ||= question_params.fetch(:questions, {})
  end
end
