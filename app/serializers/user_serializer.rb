class UserSerializer < ActiveModel::Serializer
  attributes :id, :name, :email, :image_url, :role, :admin?

  has_one :organization

  def role
    "manager"
  end
end
