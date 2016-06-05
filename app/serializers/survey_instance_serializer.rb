class SurveyInstanceSerializer < Plain::SurveyInstanceSerializer
  class QuestionSerializer < Plain::QuestionSerializer
    attributes :answers

    def answers
      []
    end
  end

  attributes :previous_goals, :questions

  has_many :questions, serializer: QuestionSerializer

  def previous_goals
    []
  end

  def questions
    object.survey_template.ordered_questions
  end
end
