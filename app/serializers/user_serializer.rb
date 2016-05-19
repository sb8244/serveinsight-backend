class UserSerializer < ActiveModel::Serializer
  attributes :id, :name, :email

  has_one :organization_membership
  has_one :organization
end
