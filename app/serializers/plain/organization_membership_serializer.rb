class Plain::OrganizationMembershipSerializer < ActiveModel::Serializer
  attributes :id, :name, :email, :admin?
end
