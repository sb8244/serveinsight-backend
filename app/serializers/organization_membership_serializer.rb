class OrganizationMembershipSerializer < Plain::OrganizationMembershipSerializer
  attributes :reviewer_id, :role

  has_one :organization
  has_many :direct_reports, serializer: Plain::OrganizationMembershipSerializer
  has_one :reviewer, serializer: Plain::OrganizationMembershipSerializer

  def reviewer_id
    object.reviewer.try!(:id)
  end

  def role
    if object.direct_reports.exists?
      "manager"
    else
      ""
    end
  end
end
