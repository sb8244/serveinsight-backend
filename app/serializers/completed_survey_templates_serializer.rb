class CompletedSurveyTemplatesSerializer < Plain::SurveyTemplateSerializer
  class SurveyInstanceSerializer < Plain::SurveyInstanceSerializer
    has_one :organization_membership, serializer: Plain::OrganizationMembershipSerializer
  end

  has_many :survey_instances, serializer: SurveyInstanceSerializer

  def survey_instances
    if object.association(:survey_instances).loaded?
      object.survey_instances
    end
  end
end
