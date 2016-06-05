class SurveyInstanceSerializer < Plain::SurveyInstanceSerializer
  class QuestionSerializer < Plain::QuestionSerializer
    attributes :answers

    def answers
      []
    end
  end

  attributes :previous_goals, :questions, :goals_section?

  has_many :questions, serializer: QuestionSerializer

  def previous_goals
    []
  end

  def questions
    object.survey_template.ordered_questions
  end

  def goals_section?
    object.survey_template.goals_section?
  end
end
