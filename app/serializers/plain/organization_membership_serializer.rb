class Plain::OrganizationMembershipSerializer < ActiveModel::Serializer
  attributes :id, :name, :email, :role, :admin?

  def role
    "manager"
  end
end
