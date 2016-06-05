class SurveyInstanceSerializer < Plain::SurveyInstanceSerializer
  attributes :previous_goals, :questions

  has_many :questions, serializer: Plain::QuestionSerializer

  def previous_goals
    []
  end

  def questions
    object.survey_template.ordered_questions
  end
end
