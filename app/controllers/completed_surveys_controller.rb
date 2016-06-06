class CompletedSurveysController < ApplicationController
  def create
    return need_answers_response unless all_questions_have_answers?
    return need_goals_response if survey_template.goals_section? && !goals_present?

    SurveyInstance.transaction do
      survey_instance.update!(completed_at: Time.now)
      add_answers!
      add_goals!
      head :no_content
    end
  end

  private

  def need_answers_response
    render json: { errors: ["All questions must have answers"] }, status: :unprocessable_entity
  end

  def need_goals_response
    render json: { errors: ["This survey requires goals"] }, status: :unprocessable_entity
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
      survey_instance.answers.create!(
        organization: current_organization,
        question_id: question.id,
        question_content: question.question,
        question_order: question.order,
        content: answer[:content],
        order: i
      )
    end
  end

  def add_goals!
    return unless survey_template.goals_section?
    goal_answers.each_with_index do |goal, i|
      survey_instance.goals.create!(
        organization: current_organization,
        content: goal[:content],
        order: i
      )
    end
  end

  def all_questions_have_answers?
    (survey_question_ids - question_ids_with_answers.to_a).empty?
  end

  def goals_present?
    goal_answers.any?
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
      answer[:question_id] && answer[:content].present?
    end
  end

  def question_ids_with_answers
    content_answers.inject(Set.new) do |ids, answer|
      ids << answer[:question_id].to_i
    end
  end
end