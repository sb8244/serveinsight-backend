class InviteSerializer < ActiveModel::Serializer
  attributes :id, :email, :admin, :accepted
end
