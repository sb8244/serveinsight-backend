class SurveyTemplateSerializer < Plain::SurveyTemplateSerializer
  has_many :questions, serializer: Plain::QuestionSerializer
end
