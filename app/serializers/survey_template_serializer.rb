class SurveyTemplateSerializer < Plain::SurveyTemplateSerializer
  attributes :response_count, :users_in_scope, :creator

  has_many :questions, serializer: Plain::QuestionSerializer

  def questions
    object.ordered_questions
  end

  def users_in_scope
    options.fetch(:users_in_scope)
  end

  def response_count
    42
  end

  def creator
    object.creator.try!(:name) || "N/A"
  end
end
