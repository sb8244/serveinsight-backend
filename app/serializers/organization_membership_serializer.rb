class OrganizationMembershipSerializer < Plain::OrganizationMembershipSerializer
  attributes :reviewer_id

  has_one :organization
  has_many :direct_reports, serializer: Plain::OrganizationMembershipSerializer
  has_one :reviewer, serializer: Plain::OrganizationMembershipSerializer

  def reviewer_id
    object.reviewer.try!(:id)
  end
end
