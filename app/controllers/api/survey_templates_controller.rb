class Api::SurveyTemplatesController < Api::BaseController
  def index
    respond_with :api, survey_templates, users_in_scope: users_in_scope
  end

  def show
    respond_with :api, survey_template, users_in_scope: users_in_scope
  end

  def create
    respond_with :api, created_template, users_in_scope: users_in_scope
  end

  def update
    update_template!
    respond_with :api, survey_template, users_in_scope: users_in_scope
  end

  private

  def users_in_scope
    current_organization.organization_memberships.count
  end

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
      CreateSurveyInstancesJob.perform_later(template)
    end
  end

  def update_template!
    survey_template.update!(template_params) if template_params.any?
    survey_template.update_instances_due! if template_params.key?(:next_due_at)
    return unless update_question_params.any?

    delete_questions_not_in_update!
    update_questions_in_update!
  end

  def template_params
    params.permit(:name, :goals_section, :weeks_between_due).tap do |p|
      p[:next_due_at] = DateTime.strptime(params.fetch(:first_due_at), "%m/%d/%Y %H:%M %z") if params.key?(:first_due_at)
      p[:recurring] = false if params.key?(:weeks_between_due) && params[:weeks_between_due].nil?
    end
  end

  def question_params
    params.permit(questions: [:id, :question, :question_type])
  end

  def update_question_params
    @update_question_params ||= question_params.fetch(:questions, {})
  end

  def delete_questions_not_in_update!
    keep_ids = update_question_params.map { |h| h[:id] }.compact
    survey_template.questions.where.not(id: keep_ids).update_all(deleted: true)
  end

  def update_questions_in_update!
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
