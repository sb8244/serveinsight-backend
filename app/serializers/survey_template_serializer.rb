class SurveyTemplateSerializer < Plain::SurveyTemplateSerializer
  attributes :response_count, :users_in_scope

  has_many :questions, serializer: Plain::QuestionSerializer

  def questions
    object.ordered_questions
  end

  def users_in_scope
    42
  end

  def response_count
    42
  end
end
