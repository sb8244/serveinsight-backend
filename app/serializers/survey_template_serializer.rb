class SurveyTemplateSerializer < Plain::SurveyTemplateSerializer
  has_many :questions, serializer: Plain::QuestionSerializer

  def questions
    object.ordered_questions
  end
end
