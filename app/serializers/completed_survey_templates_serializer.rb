class CompletedSurveyTemplatesSerializer < Plain::SurveyTemplateSerializer
  has_many :survey_instances, serializer: Plain::SurveyInstanceSerializer

  def survey_instances
    if object.association(:survey_instances).loaded?
      object.survey_instances
    end
  end
end
