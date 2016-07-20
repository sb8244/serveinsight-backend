class ShoutoutSerializer < Plain::ShoutoutSerializer
  has_one :shouted_by, serializer: Plain::OrganizationMembershipSerializer
end
