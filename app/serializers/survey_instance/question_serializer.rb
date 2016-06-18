class SurveyInstance::QuestionSerializer < Plain::QuestionSerializer
  has_many :answers, serializer: SurveyInstance::AnswerSerializer

  def answers
    return options[:answers] if options[:answers]

    options.fetch(:survey_instance).
      answers.
      where(question_id: object.id).
      order(order: :asc).
      includes(:comments)
  end
end
