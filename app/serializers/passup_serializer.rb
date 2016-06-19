class PassupSerializer < Plain::PassupSerializer
  class AnswerSerializer < SurveyInstance::AnswerSerializer
    has_one :organization_membership, serializer: Plain::OrganizationMembershipSerializer
  end

  class GoalSerializer < SurveyInstance::GoalSerializer
    has_one :organization_membership, serializer: Plain::OrganizationMembershipSerializer
  end

  PASSUPABLE_SERIALIZERS = {
    "Answer" => AnswerSerializer,
    "Goal" => GoalSerializer
  }

  attributes :passup_grant

  has_one :passed_up_by, serializer: Plain::OrganizationMembershipSerializer
  has_one :passupable

  def passup_grant
    PassupGrant.encode(object.passupable)
  end

  def passupable
    serializer = PASSUPABLE_SERIALIZERS[object.passupable_type]
    serializer.new(object.passupable, scope: scope)
  end
end
