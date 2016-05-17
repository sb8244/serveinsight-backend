class UserSerializer < ActiveModel::Serializer
  attributes :id, :name, :email, :image_url, :role, :admin?, :organization_admin?

  has_one :organization

  def role
    "manager"
  end
end
