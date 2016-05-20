class InviteSerializer < ActiveModel::Serializer
  attributes :id, :email, :name, :admin?, :accepted

  has_one :organization_membership
end
