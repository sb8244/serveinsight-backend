class CompletedSurveysController < ApplicationController
  def index
    if params[:all_reports]
      all_report_ids = Tree::Reviewer.new(current_organization_membership).all_reports.map(&:id)
      respond_with survey_templates_with_completed_instances(ids: all_report_ids), each_serializer: CompletedSurveyTemplatesSerializer
    else
      respond_with survey_templates_with_completed_instances, each_serializer: CompletedSurveyTemplatesSerializer
    end
  end

  def create
    return already_completed_response if survey_instance.completed_at.present?
    return need_answers_response unless all_questions_have_answers?
    return need_goals_response if survey_template.goals_section? && !goals_present?
    return needs_previous_goals_response if !all_previous_goals_updated?

    SurveyInstance.transaction do
      survey_instance.update!(completed_at: Time.now)
      add_answers!
      add_goals!
      update_previous_goals!
      head :no_content
    end
  end

  private

  def survey_templates_with_completed_instances(ids: [current_organization_membership.id])
    current_organization.survey_templates.
      includes(survey_instances: [:organization_membership]).
      where(survey_instances: { organization_membership_id: ids }).
      merge(SurveyInstance.completed.order(completed_at: :desc)).
      distinct
  end

  def already_completed_response
    render json: { errors: ["This survey cannot be submitted twice"] }, status: :unprocessable_entity
  end

  def need_answers_response
    render json: { errors: ["All questions must have answers"] }, status: :unprocessable_entity
  end

  def need_goals_response
    render json: { errors: ["This survey requires goals"] }, status: :unprocessable_entity
  end

  def needs_previous_goals_response
    render json: { errors: ["All previous goals must be updated"] }, status: :unprocessable_entity
  end

  def survey_instance
    @survey_instance ||= current_organization_membership.survey_instances.find(params[:survey_instance_id])
  end

  def survey_template
    @survey_template ||= survey_instance.survey_template
  end

  def question_by_id(id)
    survey_template.questions.find(id)
  end

  def add_answers!
    content_answers.each_with_index do |answer, i|
      question = question_by_id(answer[:question_id])
      answer = survey_instance.answers.create!(
        organization: current_organization,
        question_id: question.id,
        question_content: question.question,
        question_order: question.order,
        question_type: question.question_type,
        content: answer[:content],
        number: answer[:number],
        order: i
      )

      Mention::Creator.new(answer, current_organization_membership).call(answer.content) if answer.content
    end
  end

  def add_goals!
    return unless survey_template.goals_section?
    goal_answers.each_with_index do |goal, i|
      goal = survey_instance.goals.create!(
        organization: current_organization,
        content: goal[:content],
        order: i
      )
      Mention::Creator.new(goal, current_organization_membership).call(goal.content)
    end
  end

  def all_questions_have_answers?
    (survey_question_ids - question_ids_with_answers.to_a).empty?
  end

  def goals_present?
    goal_answers.any?
  end

  def all_previous_goals_updated?
    return true unless survey_instance.previous_instance.present? && survey_instance.previous_instance.goals.exists?

    previous_goal_ids = survey_instance.previous_instance.goals.pluck(:id)
    (previous_goal_ids - params.fetch(:goal_statuses, {}).keys.map(&:to_i)).empty?
  end

  def update_previous_goals!
    params.fetch(:goal_statuses, {}).each do |goal_id, status|
      survey_instance.previous_instance.goals.find(goal_id).update!(status: status)
    end
  end

  def goal_answers
    params.fetch(:goals, []).select do |goal|
      goal[:content].present?
    end
  end

  def survey_question_ids
    survey_template.questions.current.pluck(:id)
  end

  def content_answers
    @content_answers ||= params.fetch(:answers, []).select do |answer|
      question = survey_template.questions.find_by(id: answer[:question_id])
      valid = if question.try!(:question_type) === "string"
        answer[:content].present?
      elsif question.try!(:question_type) === "num5"
        answer[:number].present? && answer[:number].to_i >= 1 && answer[:number].to_i <= 5
      end

      question && valid
    end
  end

  def question_ids_with_answers
    content_answers.inject(Set.new) do |ids, answer|
      ids << answer[:question_id].to_i
    end
  end
end
