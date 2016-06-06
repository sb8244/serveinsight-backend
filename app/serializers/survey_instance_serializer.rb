class SurveyInstanceSerializer < Plain::SurveyInstanceSerializer
  class QuestionSerializer < Plain::QuestionSerializer
    has_many :answers, serializer: Plain::AnswerSerializer

    def answers
      options.fetch(:survey_instance).answers.where(question_id: object.id).order(order: :asc)
    end
  end

  attributes :previous_goals, :questions, :goals_section?

  def previous_goals
    []
  end

  def questions
    object.survey_template.ordered_questions.map do |question|
      QuestionSerializer.new(question, survey_instance: object)
    end
  end

  def goals_section?
    object.survey_template.goals_section?
  end
end
